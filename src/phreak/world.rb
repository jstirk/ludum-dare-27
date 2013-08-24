require 'phreak/entities/player'
require 'phreak/entities/cctv'
require 'phreak/entities/access_point'
require 'phreak/map'

module Phreak
  class World

    attr_reader :map, :player, :entities

    def initialize
      @map = Map.new(20,20)

      @observers = {}

      @entity_idx = 0
      @entities = {}

      @player = Entities::Player.new(self)
      register_entity(@player)

      prepare_map
    end

    def to_s
      "#<#{self.class.name}>"
    end
    alias :inspect :to_s

    def update(container, delta)
      @entities.each do |id, entity|
        entity.update(delta)
      end
    end

    def register_entity(entity)
      @entities[@entity_idx] = entity
      entity.id = @entity_idx
      @entity_idx += 1
    end

    def register_presence(old_pos, new_pos, entity)
      frequencies = entity.frequencies

      if old_pos then
        ocell = @map[old_pos]
        if ocell[:presence] then
          ocell[:presence] -= [ entity ]
        end

        # Flush all the old observational data for this entity
        # TODO: DRY this up, and move it somewhere more sensible
        frequencies.each do |type, range|
          vr = range
          (old_pos[0]-vr).upto(old_pos[0]+vr) do |x|
            next if x < 0 || x > (@map.width-1)

            (old_pos[1]-vr).upto(old_pos[1]+vr) do |y|
              next if y < 0 || y > (@map.height-1)
              pos = [x,y]
              @observers[type][pos].delete(entity.id)
            end
          end
        end
      end

      ncell = @map[new_pos]
      ncell[:presence] ||= []
      ncell[:presence] << entity

      # For each cell this entity can observe, register them
      # against the @observers
      # TODO: DRY this up, and move it somewhere more sensible
      frequencies.each do |type, range|
        vr = range
        (new_pos[0]-vr).upto(new_pos[0]+vr) do |x|
          next if x < 0 || x > (@map.width-1)

          (new_pos[1]-vr).upto(new_pos[1]+vr) do |y|
            next if y < 0 || y > (@map.height-1)
            pos = [x,y]
            @observers[type] ||= {}
            @observers[type][pos] ||= {}
            @observers[type][pos][entity.id] = entity
          end
        end
      end

      transmit(new_pos, entity, :visual)
    end

    def transmit(pos, entity, frequency=:visual, data={})
      if @observers[frequency] && @observers[frequency][pos] then
        @observers[frequency][pos].each do |id, observer|
          next if observer == entity
          observer.observe(pos, entity, frequency, data)
        end
      end
    end

  private

    def prepare_map
      %w( S...................
          ....................
          ....................
          ....................
          ....................
          ......H.............
          ....................
          ....................
          ....................
          ............XXXXXXXX
          ......C...........PX
          ............XXXXXXXX
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ...........C........ ).each_with_index do |line, y|
        line.split('').each_with_index do |character, x|
          cell = case character
          when 'X'
            { :type => :wall }
          else
            {}
          end
          @map[[x,y]] = cell

          if character == 'P' then
            @player.pos = [x,y]
          elsif character == 'C' then
            cctv = Entities::CCTV.new(self)
            register_entity(cctv)
            cctv.pos = [x,y]
          elsif character == 'H' then
            ap = Entities::AccessPoint.new(self)
            register_entity(ap)
            ap.pos = [x,y]
          end
        end
      end
    end


  end
end

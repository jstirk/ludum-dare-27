require 'phreak/entities/player'
require 'phreak/entities/cctv'
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
    end

    def register_entity(entity)
      @entities[@entity_idx] = entity
      entity.id = @entity_idx
      @entity_idx += 1
    end

    def register_presence(old_pos, new_pos, entity)
      vr = entity.view_radius

      if old_pos then
        ocell = @map[old_pos]
        if ocell[:presence] then
          ocell[:presence] -= [ entity ]
        end

        # Flush all the old observational data for this entity
        # TODO: DRY this up, and move it somewhere more sensible
        (old_pos[0]-vr).upto(old_pos[0]+vr) do |x|
          (old_pos[1]-vr).upto(old_pos[1]+vr) do |y|
            pos = [x,y]
            @observers[pos].delete(entity.id)
          end
        end
      end

      ncell = @map[new_pos]
      ncell[:presence] ||= []
      ncell[:presence] << entity

      # For each cell this entity can observe, register them
      # against the @observers
      # TODO: DRY this up, and move it somewhere more sensible
      (new_pos[0]-vr).upto(new_pos[0]+vr) do |x|
        (new_pos[1]-vr).upto(new_pos[1]+vr) do |y|
          pos = [x,y]
          @observers[pos] ||= {}
          @observers[pos][entity.id] = entity
        end
      end

      observe(new_pos, entity)
    end

    def observe(pos, entity)
      if @observers[pos] then
        @observers[pos].each do |id, observer|
          next if observer == entity
          observer.observe(pos, entity)
        end
      end
    end

  private

    def prepare_map
      %w( ....................
          ....................
          ....................
          ....................
          ....................
          ....................
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
            cctv.pos = [x,y]
            register_entity(cctv)
          end
        end
      end
    end


  end
end

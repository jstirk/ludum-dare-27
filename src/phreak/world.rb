require 'phreak/packet'
require 'phreak/entities/player'
require 'phreak/entities/cctv'
require 'phreak/entities/access_point'
require 'phreak/entities/server'
require 'phreak/entities/cell_tower'
require 'phreak/entities/goon'
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
      if old_pos then
        ocell = @map[old_pos]
        if ocell[:presence] then
          ocell[:presence] -= [ entity ]
        end
      end

      ncell = @map[new_pos]
      ncell[:presence] ||= []
      ncell[:presence] << entity

      register_observance(old_pos, new_pos, entity)

      transmit(new_pos, entity, :visual)
    end

    def register_observance(old_pos, new_pos, entity)
      frequencies = entity.frequencies

      if old_pos then
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
    end

    def observed?(pos, frequency, entity=nil)
      if @observers[frequency] && @observers[frequency][pos] then
        if entity.nil? then
          return @observers[frequency][pos].count > 0
        else
          return @observers[frequency][pos].include?(entity.id)
        end
      end
    end

    def transmit(pos, entity, frequency=:visual, data=nil)
      if observed?(pos, frequency) then
        @observers[frequency][pos].each do |id, observer|
          next if observer == entity
          observer.observe(pos, entity, frequency, data)
        end
      end
    end

  private

    def prepare_map
      mdf = nil
      idf = nil
      cctvs = []
      server = nil
      cell_tower = nil
      goon = nil
      %w( Sg.................c
          ....................
          ..M.................
          ....................
          ....................
          ......I.............
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

          case character
          when 'P'
            @player.pos = [x,y]
          when 'g'
            goon = Entities::Goon.new(self)
            register_entity(goon)
            goon.pos = [x,y]
          when 'C' then
            cctv = Entities::CCTV.new(self)
            register_entity(cctv)
            cctv.pos = [x,y]
            cctvs << cctv
          when 'I', 'M'
            ap = Entities::AccessPoint.new(self)
            register_entity(ap)
            ap.pos = [x,y]
            if character == 'M' then
              mdf = ap
            else
              idf = ap
            end
          when 'c'
            cell_tower = Entities::CellTower.new(self)
            register_entity(cell_tower)
            cell_tower.pos = [x,y]
          when 'S'
            server = Entities::Server.new(self)
            register_entity(server)
            server.pos = [x,y]
          end
        end
      end

      # Now associate the devices correctly
      mdf.associate(server)
      idf.associate(mdf)
      cctvs.each do |cctv|
        cctv.associate(idf)
      end
      server.associate(cell_tower)
      goon.associate(cell_tower)
    end

  end
end

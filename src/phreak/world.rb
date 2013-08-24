require 'phreak/entities/player'
require 'phreak/entities/cctv'
require 'phreak/map'

module Phreak
  class World

    attr_reader :map, :player, :entities

    def initialize
      @map = Map.new(20,20)

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
      if old_pos then
        ocell = @map[old_pos]
        if ocell[:presence] then
          ocell[:presence] -= [ entity ]
        end
      end

      ncell = @map[new_pos]
      ncell[:presence] ||= []
      ncell[:presence] << entity
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

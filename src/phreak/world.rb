require 'phreak/entities/player'
require 'phreak/map'

module Phreak
  class World

    attr_reader :map, :player, :entities

    def initialize
      @map = Map.new(20,20)

      @entities = {}

      @player = Entities::Player.new(self)
      @player.pos = @map.player_pos
    end

    def update(container, delta)
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

  end
end

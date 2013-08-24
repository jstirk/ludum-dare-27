require 'phreak/entities/player'
require 'phreak/map'

module Phreak
  class World

    attr_reader :map, :player, :entities

    def initialize
      @map = Map.new(20,20)

      @entities = {}

      @player = Entities::Player.new
      @player.pos = @map.player_pos
    end

    def update(container, delta)
    end

  end
end

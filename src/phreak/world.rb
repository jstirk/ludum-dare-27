require 'phreak/entities/player'
require 'phreak/map'

module Phreak
  class World

    def initialize
      @map = Map.new(40,40)

      @entities = {}

      @player = Entities::Player.new
      @player.pos = [20,20]
    end

    def update(delta)
    end

  end
end

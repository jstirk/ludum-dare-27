$:.push File.expand_path('../../lib', __FILE__)
$:.push File.expand_path('../', __FILE__)

require 'java'
require 'lwjgl.jar'
require 'slick.jar'

java_import org.newdawn.slick.state.StateBasedGame
java_import org.newdawn.slick.GameContainer
java_import org.newdawn.slick.Graphics
java_import org.newdawn.slick.Image
java_import org.newdawn.slick.Input
java_import org.newdawn.slick.SlickException
java_import org.newdawn.slick.AppGameContainer

require 'states/map_state'
require 'phreak/world'
# require 'phreak/ui_handler'

module Phreak
  class Game < StateBasedGame

    attr_reader :world, :ui_handler

    def initialize(name)
      super

      # @ui_handler = UIHandler.new

      @world = World.new
      # @world.ui_handler = @ui_handler
    end

    def player
      @world.player
    end

    def initStatesList(container)
      self.add_state(MapState.new)
    end
  end
end

# WIDTH = 1280
# HEIGHT = 720
# FULLSCREEN = true

WIDTH = 1000
HEIGHT = 700
FULLSCREEN = false

app = AppGameContainer.new(Phreak::Game.new('Phreak'))
app.set_display_mode(WIDTH, HEIGHT, FULLSCREEN)
app.start

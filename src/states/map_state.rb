java_import org.newdawn.slick.state.BasicGameState
java_import org.newdawn.slick.Color
java_import org.newdawn.slick.SpriteSheet

module Phreak
  class MapState < BasicGameState

    def getID
      1
    end

    def init(container, game)
      @tile_width = 32
      @tile_height = 32

      @game  = game
      @world = @game.world
      @player = @game.player

      @map = @world.map

      @x = @player.pos[0]
      @y = @player.pos[1]

      @sprites = SpriteSheet.new('data/spritesheet.png', 32, 32)
      @ground = @sprites.getSprite(0,0)
      @wall   = @sprites.getSprite(1,0)
      @avatar = @sprites.getSprite(3,0)

      @cctv_cold = @sprites.getSprite(0,1)
      @cctv_hot  = @sprites.getSprite(1,1)

      @target_connected    = @sprites.getSprite(0,2)
      @target_disconnected = @sprites.getSprite(2,2)
    end

    def render(container, game, graphics)
      @targets = {}

      @ox = (container.width >> 1) - (@x * @tile_width) - (@tile_width / 2)
      @oy = (container.height >> 1) - (@y * @tile_height) - (@tile_height / 2)

      cells_wide = container.width / @tile_width
      cells_high = container.width / @tile_height

      fx = [0, @x - (cells_wide >> 1)].max
      fy = [0, @y - (cells_high >> 1)].max
      cx = [@x + (cells_wide >> 1), @map.width - 1 ].min
      cy = [@y + (cells_high >> 1), @map.height - 1].min

      fx.upto(cx) do |x|
        fy.upto(cy) do |y|
          vpos = project(x,y)

          cell = @map.cell(x,y)

          render_tile(cell, vpos[0], vpos[1], x, y)

          if cell[:presence] then
            cell[:presence].each do |entity|
              render_entity(entity, vpos[0], vpos[1], x, y)
            end
          end
        end
      end

      # TODO: Render overlay to target
      # TODO: Render device overlay if in that mode

      graphics.draw_string("#{[@x,@y].inspect} (ESC to exit)", 8, container.height - 30)
    end

    def update(container, game, delta)
      input = container.get_input
      container.exit if input.is_key_down(Input::KEY_ESCAPE)

      if @map then
        touched = false
        if input.is_key_down(Input::KEY_A) then
          @x -= 1
          touched = true
        end
        if input.is_key_down(Input::KEY_D) then
          @x += 1
          touched = true
        end
        if input.is_key_down(Input::KEY_W)
          @y -= 1
          touched = true
        end
        if input.is_key_down(Input::KEY_S)
          @y += 1
          touched = true
        end

        if touched then
          @x = 0 if @x < 0
          @y = 0 if @y < 0
          @x = @map.width-1 if @x >= @map.width
          @y = @map.height-1 if @y >= @map.height

          @player.pos = [@x,@y]
        end
      end

      @world.update(container, delta)
    end

    def mouseClicked(button, x, y, count)
      pos = deproject(x,y)
      target = @targets[pos]
      puts "CLICKED: #{pos.inspect} = #{target.inspect}"
      @player.current_target = target
    end

    def keyPressed(key, char_code)
      # TODO: Tones on numberpad if device is open
    end

    def keyReleased(key, char_code)
      char = char_code.chr

      case char
      when '`'
        # Open or close the device
        @device = !@device

        if @device then
          puts "1. DISABLE"
        end
      when '1'
        if @device && @player.current_target && @player.current_target.respond_to?(:disable!) then
          @player.current_target.disable!
        end
      when '2'
        if @device then
          @game.player.wiresniff!
        end
      end
    end

  private

    # Projects a tile [x,y] coordinate into a screen coordinate, taking
    # the current viewport into account.
    def project(x,y)
      [ @ox + (x * @tile_width), @oy + (y * @tile_height) ]
    end

    def deproject(vx,vy)
      [ ((vx - @ox) / @tile_width.to_f).floor, ((vy - @oy) / @tile_height.to_f).floor ]
    end

    def render_tile(cell, vx, vy, x, y)
      image = case cell[:type]
      when :wall
        @wall
      else
        @ground
      end
      image.draw(vx, vy, 1.0)
    end

    def render_entity(entity, vx, vy, x, y)
      image = case entity
      when Entities::Player
        @avatar
      when Entities::CCTV, Entities::AccessPoint, Entities::Server
        @targets[[x,y]] = entity
        if entity.active? then
          @cctv_hot
        else
          @cctv_cold
        end
      else
        @cctv
      end

      image.draw(vx, vy, 1.0)

      if entity == @player.current_target then
        if !entity.respond_to?(:crypto_key) || @player.known_crypto_key?(entity.crypto_key) then
          @target_connected.draw(vx, vy, 1.0)
        else
          @target_disconnected.draw(vx, vy, 1.0)
        end
      end
    end

  end
end

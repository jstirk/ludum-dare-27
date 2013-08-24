java_import org.newdawn.slick.state.BasicGameState
java_import org.newdawn.slick.Color
java_import org.newdawn.slick.SpriteSheet

class MapState < BasicGameState

  def getID
    1
  end

  def init(container, game)
    @tile_width = 32
    @tile_height = 32

    @world = game.world

    @map = @world.map

    @x = game.player.pos[0]
    @y = game.player.pos[1]

    @sprites = SpriteSheet.new('data/spritesheet.png', 32, 32)
    @ground = @sprites.getSprite(0,0)
    @wall   = @sprites.getSprite(0,1)
    @cctv   = @sprites.getSprite(2,0)
  end

  def render(container, game, graphics)
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
      end
    end

    graphics.draw_string("#{[@x,@y].inspect} (ESC to exit)", 8, container.height - 30)
  end

  def update(container, game, delta)
    input = container.get_input
    container.exit if input.is_key_down(Input::KEY_ESCAPE)

    if @map then
      if input.is_key_down(Input::KEY_A) then
        @x -= 1
      end
      if input.is_key_down(Input::KEY_D) then
        @x += 1
      end
      if input.is_key_down(Input::KEY_W)
        @y -= 1
      end
      if input.is_key_down(Input::KEY_S)
        @y += 1
      end

      @x = 0 if @x < 0
      @y = 0 if @y < 0
      @x = @map.width-1 if @x >= @map.width
      @y = @map.height-1 if @y >= @map.height
    end

    @world.update(container, delta)
  end

private

  # Projects a tile [x,y] coordinate into a screen coordinate, taking
  # the current viewport into account.
  def project(x,y)
    [ @ox + (x * @tile_width), @oy + (y * @tile_height) ]
  end

  def render_tile(cell, vx, vy, x, y)
    image = case cell[:type]
    when :wall
      @wall
    when :cctv
      @cctv
    else
      @ground
    end
    image.draw(vx, vy, 1.0)
    # unless x == @x && y == @y then
    #   @ground.draw(vx, vy, 1.0)
    # end
  end

end

java_import org.newdawn.slick.state.BasicGameState
java_import org.newdawn.slick.Color

class MapState < BasicGameState

  def getID
    1
  end

  def init(container, game)
    @tile_width = 32
    @tile_height = 32

    @map = game.world.map

    @x = game.player.pos[0]
    @y = game.player.pos[1]
  end

  def render(container, game, graphics)
    cells_wide = container.width / @tile_width
    cells_high = container.width / @tile_height

    0.upto(cells_wide) do |ix|
      0.upto(cells_high) do |iy|
        x = @x - (cells_wide >> 1) + ix
        y = @y - (cells_high >> 1) + iy

        next if x < 0 || y < 0 || x > (@map.width-1) || y > (@map.height-1)

        cell = @map.cell(x,y)

        vx = ix * @tile_width
        vy = iy * @tile_width

        render_tile(graphics, cell, vx, vy, x, y)

      end
    end
  end

  def update(container, game, delta)
  end

private

  def render_tile(graphics, cell, vx, vy, x, y)
    graphics.setColor(Color.new(255,255,255,255))
    graphics.drawRect(vx,vy, @tile_width, @tile_height)
  end

end

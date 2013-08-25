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
      @ix = @x.floor
      @iy = @y.floor

      @sprites = SpriteSheet.new('data/spritesheet.png', 32, 32)
      @ground = @sprites.getSprite(0,0)
      @wall   = @sprites.getSprite(1,0)
      @avatar = @sprites.getSprite(3,0)

      @cctv_cold = @sprites.getSprite(0,1)
      @cctv_hot  = @sprites.getSprite(1,1)

      @target_connected    = @sprites.getSprite(0,2)
      @target_disconnected = @sprites.getSprite(2,2)

      @visual_overlay = @sprites.getSprite(0,3)
      @wifi_overlay = @sprites.getSprite(1,3)

      @phone = Image.new('data/phone.png')
    end

    def render(container, game, graphics)
      @targets = {}
      @graphics = graphics
      @container = container

      @ox = (container.width >> 1) - (@x * @tile_width) - (@tile_width / 2)
      @oy = (container.height >> 1) - (@y * @tile_height) - (@tile_height / 2)

      cells_wide = container.width / @tile_width
      cells_high = container.width / @tile_height

      fx = [0, @ix - (cells_wide >> 1)].max
      fy = [0, @iy - (cells_high >> 1)].max
      cx = [@ix + (cells_wide >> 1), @map.width - 1 ].min
      cy = [@iy + (cells_high >> 1), @map.height - 1].min

      entities = []
      visual_overlay  = []
      wifi_overlay = []

      fx.upto(cx) do |x|
        fy.upto(cy) do |y|
          vpos = project(x,y)

          cell = @map.cell(x,y)

          render_tile(cell, vpos[0], vpos[1], x, y)

          if cell[:presence] then
            entities += cell[:presence]
          end

          if @world.observed?([x,y], :visual) then
            visual_overlay << [x,y]
          end

          if @world.observed?([x,y], :wifi, @player) then
            wifi_overlay << [x,y]
          elsif @player.current_target && @world.observed?([x,y], :wifi, @player.current_target) then
            if !@player.current_target.respond_to?(:disabled?) || !@player.current_target.disabled? then
              wifi_overlay << [x,y]
            end
          end
        end
      end

      if @device then
        wifi_overlay.each do |pos|
          ovpos = project(pos[0], pos[1])
          render_overlay(:wifi, ovpos[0], ovpos[1], pos[0], pos[1])
        end
      end

      visual_overlay.each do |pos|
        ovpos = project(pos[0], pos[1])
        render_overlay(:visual, ovpos[0], ovpos[1], pos[0], pos[1])
      end


      entities.each do |entity|
        evpos = project(entity.exact_pos[0], entity.exact_pos[1])
        epos  = entity.pos
        render_entity(entity, evpos[0], evpos[1], epos[0], epos[1])
      end

      # Render device overlay if in that mode
      render_device_overlay

      graphics.draw_string("#{[@ix,@iy].inspect} (ESC to exit)", 8, container.height - 30)
    end

    def update(container, game, delta)
      input = container.get_input
      container.exit if input.is_key_down(Input::KEY_ESCAPE)

      if @map then
        touched = false
        fragment = delta / 250.0
        if input.is_key_down(Input::KEY_A) then
          @x -= 1.0 * fragment
          touched = true
        end
        if input.is_key_down(Input::KEY_D) then
          @x += 1.0 * fragment
          touched = true
        end
        if input.is_key_down(Input::KEY_W)
          @y -= 1.0 * fragment
          touched = true
        end
        if input.is_key_down(Input::KEY_S)
          @y += 1.0 * fragment
          touched = true
        end

        if touched then
          @x = 0 if @x < 0.0
          @y = 0 if @y < 0.0
          @x = @map.width-1 if @x >= @map.width
          @y = @map.height-1 if @y >= @map.height

          @ix = @x.floor
          @iy = @y.floor

          @player.exact_pos = [ @x,@y ]
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
      when '1'
        if @device && @player.can_access?(@player.current_target) && @player.current_target.respond_to?(:disable!) then
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
      when Entities::CCTV, Entities::AccessPoint, Entities::Server, Entities::CellTower
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
        if @player.can_access?(entity) then
          @target_connected.draw(vx, vy, 1.0)
        else
          @target_disconnected.draw(vx, vy, 1.0)
        end
      end

      # Render connection overlay
      if @device then
        @overlay_line_color ||= Color.new(0,0,255,255)
        @disabled_overlay_line_color ||= Color.new(255,0,0,255)
        if entity.respond_to?(:disabled?) && entity.disabled? then
          color = @disabled_overlay_line_color
        else
          color = @overlay_line_color
        end
        if @player.can_access?(entity) then
          entity.associated_entities.each do |oentity|
            epos = project(oentity.exact_pos[0], oentity.exact_pos[1])
            @graphics.drawGradientLine(vx + (@tile_width / 2), vy + (@tile_height / 2), color,
                                       epos[0] + (@tile_width / 2), epos[1] + (@tile_height / 2), color)
          end
        end
      end
    end

    def render_overlay(type, vx, vy, x, y)
      case type
      when :visual
        @visual_overlay.draw(vx, vy, 1.0)
      when :wifi
        @wifi_overlay.draw(vx, vy, 1.0)
      end
    end

    def render_device_overlay
      if @device then
        @default_font_color ||= Color.new(255,255,255,255)
        @device_font_color ||= Color.new(29,30,25,255)
        ox = 30
        oy = @container.height - 400
        @phone.draw(ox, oy, 2.0)

        @graphics.setColor(@device_font_color)
        case @player.device_state
        when :sniffing
          @graphics.draw_string("WIRESNIFF", ox + 20, oy + 60)
          vy = oy + 60
          @player.wiresniff_stats.each do |key, progress|
            vy += 20
            @graphics.draw_string(sprintf('%05d (%2.1f%%)', key, progress), ox + 20, vy)
          end
        else
          @graphics.draw_string("1. DISABLE", ox + 20, oy + 60) if @player.can_access?(@player.current_target)
          @graphics.draw_string("2. SNIFF", ox + 20, oy + 80)
        end
        @graphics.setColor(@default_font_color)
      end
    end

  end
end

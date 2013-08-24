module Phreak
  module Entities
    module Concerns
      module Disableable

        def init_disableable
          @disable_timer = nil
        end

        def disabled?
          !@disable_timer.nil?
        end

        def disable!
          @buffer = [] if @buffer
          @transmit_time = 0 if @transmit_time
          @disable_timer = 0
        end

        def update_disableable(delta)
          if @disable_timer then
            @disable_timer += delta
            if @disable_timer >= Phreak::TIME then
              @disable_timer = nil
            end
          end
        end

      end
    end
  end
end

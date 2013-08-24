module Phreak
  module Entities
    module Concerns
      module Transmitter

        def init_transmitter
          @buffer = []
          @transmit_time = 0
          @transmit_frequency = :wifi
        end

        def update_transmitter(delta)
          @transmit_time += delta
          if @transmit_time >= 1000 then

            @buffer.each do |data|
              @world.transmit(@pos, self, @transmit_frequency, data)
            end

            @buffer = []
            @transmit_time = 0
          end
        end

      end
    end
  end
end

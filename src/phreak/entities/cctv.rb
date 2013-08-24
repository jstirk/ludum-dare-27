require 'phreak/entities/base'

module Phreak
  module Entities
    class CCTV < Base

      def initialize(world)
        super

        @motion = false
        @buffer = []
        @transmit_time = 0
      end

      def update(delta)
        @transmit_time += delta
        if @transmit_time >= 5000 then
          @motion = false
          @buffer = []
          @transmit_time = 0
        end
      end

      def alerted?
        @motion || @buffer.size > 0
      end

      def observe(pos, entity)
        # TODO: Log this sight in my buffer to send out next update
        case entity
        when Player
          @buffer << { :target => entity, :pos => pos }
        else
          @motion = true
        end
      end

    end
  end
end

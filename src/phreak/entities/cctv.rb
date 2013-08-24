require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'

module Phreak
  module Entities
    class CCTV < Base

      include Concerns::Transmitter

      def initialize(world)
        super

       init_transmitter

        @motion = false
        @frequencies = { :wifi => 10, :visual => 5 }
      end

      def update(delta)
        update_transmitter(delta)
      end

      def active?
        @motion || @buffer.size > 0
      end

      def observe(pos, entity, frequency, data)
        if frequency == :visual then
          case entity
          when Player
            @buffer << Packet.new({ :target => entity, :pos => pos })
          else
            @motion = true
          end
        end
      end

    end
  end
end

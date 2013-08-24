require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'

module Phreak
  module Entities
    class AccessPoint < Base

      include Concerns::Transmitter

      def initialize(world)
        super

        init_transmitter

        @frequencies = { :wifi => 20 }
      end

      def active?
        @buffer.size > 0
      end

      def update(delta)
        update_transmitter(delta)
      end

      def observe(pos, entity, frequency, data)
        puts [self, pos, entity, data].inspect
        if frequency == :wifi then
          @buffer << data
        end
      end

    end
  end
end

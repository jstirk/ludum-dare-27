require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'
require 'phreak/entities/concerns/disableable'

module Phreak
  module Entities
    class AccessPoint < Base

      include Concerns::Transmitter
      include Concerns::Disableable

      def initialize(world)
        super

        init_disableable
        init_transmitter

        @frequencies = { :wifi => 20 }
      end

      def active?
        @buffer.size > 0
      end

      def update(delta)
        update_transmitter(delta) unless disabled?
      end

      def observe(pos, entity, frequency, data)
        unless disabled? then
          if frequency == :wifi then
            return if data.hopped?(self)
            @buffer << data
          end
        end
      end

    end
  end
end

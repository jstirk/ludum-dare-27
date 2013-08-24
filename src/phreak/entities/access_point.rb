require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'
require 'phreak/entities/concerns/disableable'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class AccessPoint < Base

      include Concerns::Transmitter
      include Concerns::Disableable
      include Concerns::Encryptable

      def initialize(world)
        super

        init_encryptable
        init_disableable
        init_transmitter

        @frequencies = { :wifi => 15 }
      end

      def active?
        @buffer.size > 0
      end

      def update(delta)
        update_encryptable(delta)
        update_disableable(delta)
        update_transmitter(delta) unless disabled?
      end

      def observe(pos, entity, frequency, data)
        unless disabled? then
          if frequency == :wifi then
            return if data.hopped?(self)
            return if data.encrypted? && !known_crypto_key?(data.crypto_key)
            @buffer << data
          end
        end
      end

    end
  end
end

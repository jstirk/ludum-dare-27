require 'phreak/entities/access_point'

module Phreak
  module Entities
    class CellTower < AccessPoint

      def initialize(world)
        super

        @frequencies = { :cell => 30 }
        @transmit_frequency = :cell
      end

      def observe(pos, entity, frequency, data)
        unless disabled? then
          if frequency == :cell then
            return if data.hopped?(self)
            return if data.encrypted? && !known_crypto_key?(data.crypto_key)
            puts "CELL IN: #{data.inspect}"
            @buffer << data
          end
        end
      end

    end
  end
end

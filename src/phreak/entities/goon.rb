require 'phreak/entities/base'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class Goon < Base

      include Concerns::Encryptable

      def initialize(world)
        super

        @frequencies = { :cell => 30 }
        @current_target = nil

        init_encryptable
      end

      def update(delta)
        if @current_target then
          puts "I NEED TO MOVE TO #{@current_target.inspect}"
        end
      end

      def observe(pos, entity, frequency, packet)
        if frequency == :cell then
          return if packet.hopped?(self)
          return if packet.encrypted? && !known_crypto_key?(packet.crypto_key)
          if packet.data[:action] == :kill then
            @current_target = packet.data[:pos]
          end
        end
      end

    end
  end
end

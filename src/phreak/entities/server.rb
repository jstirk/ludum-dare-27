require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    # A Server belongs to an Organisation and will contact all the
    # members of the Organisation when they spot a specific situation.
    # For example, the PoliceServer will look for signs of shots fired
    # and dispatch Police there.
    # The SyndicateServer will look for signs of the player, and
    # dispatch Agents to, well, deadify you.
    class Server < Base

      include Concerns::Transmitter
      include Concerns::Encryptable

      def initialize(world)
        super

        init_encryptable
        init_transmitter

        @inqueue = []
        @frequencies = { :wifi => 5 }
        @transmit_frequency = :cell
      end

      def update(delta)
        @inqueue.each do |packet|
          if packet.data[:target].is_a?(Entities::Player) then
            # Dispatch Goons to the given position
            @buffer << Packet.new(packet.data.merge(:action => :kill))
          end
        end
        @inqueue = []
        update_encryptable(delta)
        update_transmitter(delta)
      end

      def observe(pos, entity, frequency, data)
        if frequency == :wifi then
          return if data.hopped?(self)
          return if data.encrypted? && !known_crypto_key?(data.crypto_key)
          @inqueue << data
        end
      end

    end
  end
end

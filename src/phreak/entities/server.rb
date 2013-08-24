require 'phreak/entities/base'
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

      include Concerns::Encryptable

      def initialize(world)
        super

        init_encryptable

        @frequencies = { :wifi => 5 }
      end

      def observe(pos, entity, frequency, data)
        if frequency == :wifi then
          return if data.hopped?(self)
          return if data.encrypted? && !known_crypto_key?(data.crypto_key)
          puts "SERVER GOT: #{data.inspect} via #{data.hops}"
        end
      end

    end
  end
end

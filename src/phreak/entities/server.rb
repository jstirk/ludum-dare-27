require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'

module Phreak
  module Entities
    # A Server belongs to an Organisation and will contact all the
    # members of the Organisation when they spot a specific situation.
    # For example, the PoliceServer will look for signs of shots fired
    # and dispatch Police there.
    # The SyndicateServer will look for signs of the player, and
    # dispatch Agents to, well, deadify you.
    class Server < Base

      def initialize(world)
        super

        @frequencies = { :wifi => 5 }
      end

      def observe(pos, entity, frequency, data)
        if frequency == :wifi then
          puts "SERVER GOT: #{data.inspect} via #{data.hops}"
        end
      end

    end
  end
end

require 'phreak/entities/base'
require 'phreak/entities/concerns/transmitter'
require 'phreak/entities/concerns/disableable'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class CCTV < Base

      include Concerns::Transmitter
      include Concerns::Disableable
      include Concerns::Encryptable

      def initialize(world)
        super

        init_encryptable
        init_disableable
        init_transmitter

        @motion = false
        @frequencies = { :wifi => 10, :visual => 5 }
      end

      def update(delta)
        update_encryptable(delta)
        update_disableable(delta)
        update_transmitter(delta) unless disabled?
      end

      def active?
        @motion || @buffer.size > 0
      end

      def observe(pos, entity, frequency, data)
        unless disabled? then
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
end

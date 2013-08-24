require 'phreak/entities/base'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class Player < Base

      include Concerns::Encryptable

      def initialize(world)
        super

        init_encryptable

        @wiresniff_log = {}
        @wiresniff_timer = nil
      end

      def frequencies
        freq = { :visual => 10, :wifi => 10 }
        freq
      end

      def update(delta)
        update_wiresniff(delta)
        @buffer = []
      end

      def observe(pos, entity, frequency, data)
        if frequency == :wifi then
          return if @wiresniff_timer.nil? && data.encrypted? && !known_crypto_key?(data.crypto_key)
          puts "GOT: #{data.inspect}"
          @buffer << data
        end
      end

      def wiresniff!
        puts "SNIFF SNIFF!"
        @wiresniff_timer = 0
        @wiresniff_log = {}
        @world.register_observance(nil, @pos, self)
      end

    private

      def update_wiresniff(delta)
        if @wiresniff_timer then

          @buffer.each do |packet|
            @wiresniff_log[packet.crypto_key] ||= 0
            @wiresniff_log[packet.crypto_key] += 1
            if @wiresniff_log[packet.crypto_key] > 10 then
              # HOLY CRAP WE UNLOCKED IT
              @known_crypto_keys << packet.crypto_key

              puts "UNLOCKED #{packet.crypto_key}!!!!"
              @wiresniff_timer = 15000
              break
            end
          end

          @wiresniff_timer += delta
          if @wiresniff_timer >= 15000 then
            @wiresniff_timer = nil
            @world.register_observance(nil, @pos, self)
          end
        end
      end

    end
  end
end

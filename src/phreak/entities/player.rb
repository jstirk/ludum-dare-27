require 'phreak/entities/base'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class Player < Base

      CRACK_PACKETS_REQUIRED = 50

      include Concerns::Encryptable

      attr_accessor :current_target

      def initialize(world)
        super

        init_encryptable

        @wiresniff_log = {}
        @wiresniff_timer = nil
      end

      def frequencies
        freq = { :wifi => 6 }
        freq
      end

      def update(delta)
        update_wiresniff(delta)
        @buffer = []
      end

      def device_state
        if @wiresniff_timer then
          :sniffing
        else
          nil
        end
      end

      def wiresniff_stats
        out = {}
        @wiresniff_log.each do |key, count|
          out[key] = (count / CRACK_PACKETS_REQUIRED.to_f) * 100.0
        end
        out
      end

      def observe(pos, entity, frequency, data)
        if frequency == :wifi then
          return if @wiresniff_timer.nil? && data.encrypted? && !known_crypto_key?(data.crypto_key)

          puts "GOT: #{data.inspect}"
          @buffer << data
        end
      end

      def wiresniff!
        @wiresniff_timer = 0
        @wiresniff_log = {}
        @world.register_observance(nil, @pos, self)
      end

      def can_access?(entity)
        return false if entity.nil?
        entity.respond_to?(:crypto_key) && known_crypto_key?(entity.crypto_key)
      end

    private

      def update_wiresniff(delta)
        if @wiresniff_timer then

          @buffer.each do |packet|
            next if known_crypto_key?(packet.crypto_key)
            @wiresniff_log[packet.crypto_key] ||= 0
            @wiresniff_log[packet.crypto_key] += 1
            if @wiresniff_log[packet.crypto_key] > CRACK_PACKETS_REQUIRED then
              # HOLY CRAP WE UNLOCKED IT
              @known_crypto_keys << packet.crypto_key

              puts "UNLOCKED #{packet.crypto_key}!!!!"
              @wiresniff_timer = Phreak::TIME
              break
            end
          end

          @wiresniff_timer += delta
          if @wiresniff_timer >= Phreak::TIME then
            @wiresniff_timer = nil
            @world.register_observance(nil, @pos, self)
          end
        end
      end

    end
  end
end

module Phreak
  module Entities
    module Concerns
      module Encryptable

        attr_reader :crypto_key, :associated_entities

        def init_encryptable
          @crypto_key = Kernel::rand(99999)
          @known_crypto_keys = [ @crypto_key ]
          @associated_entities = []
        end

        # Associates this entity with another entity, storing the remote
        # association key in our list of known keys
        def associate(entity)
          puts "#{self.inspect} associating with #{entity.inspect} = #{entity.crypto_key}"
          @associated_entities << entity
          @known_crypto_keys << entity.crypto_key
          @known_crypto_keys.uniq!
        end

        def known_crypto_key?(key)
          @known_crypto_keys.include?(key)
        end

        def update_encryptable(delta)
          if @buffer && @known_crypto_keys.size > 0 then
            @buffer.each do |packet|
              if !packet.encrypted? || packet.crypto_key == @crypto_key then
                new_packets = []
                @known_crypto_keys.each do |key|
                  next if key == @crypto_key
                  new_packet = packet.recrypt(key)
                  new_packets << new_packet
                end
                @buffer -= [packet]
                @buffer += new_packets
              end
            end
          end
        end

      end
    end
  end
end

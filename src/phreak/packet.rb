module Phreak
  class Packet
    attr_reader :source, :hops, :data

    def initialize(data={}, hops=[])
      @data = data
      @hops = hops
    end

    def recrypt(key)
      Packet.new(data.dup.merge(:crypto_key => key), @hops)
    end

    def encrypted?
      !crypto_key.nil?
    end

    def crypto_key
      data[:crypto_key]
    end

    def hop(entity)
      @hops << entity.id
    end

    def hopped?(entity)
      @hops.include?(entity.id)
    end
  end
end

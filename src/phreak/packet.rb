module Phreak
  class Packet
    attr_reader :source, :hops
    def initialize(data={})
      @data = data
      @hops = []
    end

    def hop(entity)
      @hops << entity.id
    end

    def hopped?(entity)
      @hops.include?(entity.id)
    end
  end
end

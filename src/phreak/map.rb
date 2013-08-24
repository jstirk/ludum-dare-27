module Phreak
  class Map

    def initialize(width, height)
      @cells = {}
    end

    def cell(x,y)
      self[[x,y]]
    end

    def [](pos)
      @cell[pos] || {}
    end

  end
end

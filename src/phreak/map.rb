module Phreak
  class Map

    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @cells = {}
    end

    def cell(x,y)
      self[[x,y]]
    end

    def [](pos)
      @cells[pos] || {}
    end

    def []=(pos, cell)
      @cells[pos] = cell
    end

    def to_s
      "#<#{self.class.name}>"
    end
    alias :inspect :to_s

  private

  end
end

java_import org.newdawn.slick.util.pathfinding.TileBasedMap
java_import org.newdawn.slick.util.pathfinding.AStarPathFinder

module Phreak
  class Map

    include org.newdawn.slick.util.pathfinding.TileBasedMap

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

    def pathfinder
      AStarPathFinder.new(self, @width + @height, true)
    end

    def getWidthInTiles
      @width
    end

    def getHeightInTiles
      @height
    end

    def getCost(context, tx, ty)
      dx = (context.sourceX - tx).abs
      dy = (context.sourceY - ty).abs

      Math.sqrt((dx**2) + (dy**2))
    end

    def blocked(context, tx, ty)
      @cells[[tx, ty]][:type] == :wall
    end

    def pathFinderVisited(x,y)
    end

  private

  end
end

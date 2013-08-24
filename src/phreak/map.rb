module Phreak
  class Map

    attr_reader :width, :height

    attr_reader :player_pos

    def initialize(width, height)
      @width = width
      @height = height
      @cells = {}
      @player_pos = nil

      prepare_map
    end

    def cell(x,y)
      self[[x,y]]
    end

    def [](pos)
      @cells[pos] || {}
    end

  private

    def prepare_map
      %w( ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ............XXXXXXXX
          ......C...........PX
          ............XXXXXXXX
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ....................
          ...........C........ ).each_with_index do |line, y|
        line.split('').each_with_index do |character, x|
          if character == 'P' then
            @player_pos = [x,y]
          end

          cell = case character
          when 'C'
            # TODO: Register CCTV entity
            { :type => :cctv }
          when 'X'
            { :type => :wall }
          else
            {}
          end
          @cells[[x,y]] = cell
        end
      end
    end

  end
end

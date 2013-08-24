module Phreak
  module Entities
    # Shared logic across all the humanesque entities.
    class Base

      attr_accessor :pos, :id

      def initialize(world)
        @world = world
        @id = nil
        @pos = nil
      end

      def pos=(new_pos)
        @world.register_presence(@pos, new_pos, self)
        @pos = new_pos
      end

    end
  end
end

module Phreak
  module Entities
    # Shared logic across all the entities.
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

      def alerted?
        @alerted
      end

      # Callback when the given entity moves into the position.
      # Should be overridden in subclasses to handle action on seeing
      # someone.
      def observe(pos, entity)
      end

      # Callback for every update tick in the game. Override in
      # subclasses.
      def update(delta)
      end

      def view_radius
        5
      end

    end
  end
end

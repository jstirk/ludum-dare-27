module Phreak
  module Entities
    # Shared logic across all the entities.
    class Base

      attr_accessor :pos, :exact_pos, :id

      attr_reader :frequencies

      def initialize(world)
        @world = world
        @id = nil
        @pos = nil
        @frequencies = {}
      end

      def to_s
        "#<#{self.class.name}>"
      end
      alias :inspect :to_s

      def exact_pos=(new_pos)
        @exact_pos = new_pos
        ix = @exact_pos[0].floor
        iy = @exact_pos[1].floor
        if ix != @pos[0] || iy != @pos[1] then
          @world.register_presence(@pos, [ix,iy], self)
          @pos = [ix,iy]
        end
      end

      def pos=(new_pos)
        @world.register_presence(@pos, new_pos, self)
        @pos = new_pos
        @exact_pos = [ @pos[0], @pos[1] ]
      end

      def active?
        @active
      end

      # Callback when the given entity moves into the position.
      # Should be overridden in subclasses to handle action on seeing
      # someone.
      def observe(pos, entity, frequency, data)
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

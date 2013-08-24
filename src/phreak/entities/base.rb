module Phreak
  module Entities
    # Shared logic across all the humanesque entities.
    class Base

      attr_accessor :pos

      def initialize
        @pos = nil
      end

    end
  end
end

require 'phreak/entities/base'

module Phreak
  module Entities
    class CCTV < Base

      def observe(pos, entity)
        # TODO: Log this sight in my buffer to send out next update
        @alerted = true
      end

    end
  end
end

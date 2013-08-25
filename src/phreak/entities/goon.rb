require 'phreak/entities/base'
require 'phreak/entities/concerns/encryptable'

module Phreak
  module Entities
    class Goon < Base

      include Concerns::Encryptable

      attr_accessor :home

      def initialize(world)
        super

        @frequencies = { :visual => 3, :cell => 30 }
        @current_target = nil

        @idle_timer = nil
        @home = nil

        init_encryptable
      end

      def update(delta)
        if @current_target then
          @idle_timer = nil
          if @path.nil? then
            result = @world.map.pathfinder.findPath(self, @pos[0], @pos[1], @current_target[0], @current_target[1])
            if result && result.length > 0 then
              @path = []
              0.upto(result.length - 1) do |idx|
                step = result.getStep(idx)
                @path << [ step.getX, step.getY ]
              end
            end
          else
            current = @path.first
            dx = (current[0] - @pos[0]) * (delta / 250.0)
            dy = (current[1] - @pos[1]) * (delta / 250.0)
            new_pos = [ @exact_pos[0].to_f + dx, @exact_pos[1].to_f + dy ]
            self.exact_pos = new_pos
            if self.pos == @path.first then
              @path.shift
              if @path.first.nil? then
                @path = nil
                @current_target = nil
              end
            end
          end
        else
          @idle_timer ||= 0
          @idle_timer += delta
          if @idle_timer >= 5000 then
            @current_target = @home
            @idle_times = nil
          end
        end
      end

      def observe(pos, entity, frequency, packet)
        if frequency == :cell then
          return if packet.hopped?(self)
          return if packet.encrypted? && !known_crypto_key?(packet.crypto_key)
          if packet.data[:action] == :kill then
            @current_target = packet.data[:pos]
          end
        end
      end

    end
  end
end

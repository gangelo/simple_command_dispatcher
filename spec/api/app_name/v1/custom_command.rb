# frozen_string_literal: true

module Api
  module AppName
    module V1
      # This is a custom command that does not prepend SimpleCommand.
      class CustomCommand
        def self.call(*args)
          command = new(*args)
          if command
            command.send(:execute)
          else
            false
          end
        end

        private

        def initialize(params = {})
          @param1 = params[:param1]
        end

        attr_accessor :param1

        def execute
          return true if param1 == :param1

          false
        end
      end
    end
  end
end

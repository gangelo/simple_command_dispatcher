# frozen_string_literal: true

module Api
  module AppName
    module V2
      class InvalidCustomCommand
        # This is a custom command that does not prepend SimpleCommand.

        def call(params = {})
          @param1 = params[:param1]
          @param2 = params[:param2]
          @param3 = params[:param3]

          execute
        end

        private

        attr_accessor :param1, :param2, :param3

        def execute
          return true if param1 == :param1 && param2 == :param2 && param3 == :param3

          false
        end
      end
    end
  end
end

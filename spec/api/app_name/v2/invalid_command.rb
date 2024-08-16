# frozen_string_literal: true

module Api
  module AppName
    module V2
      class InvalidCommand
        # This is a command that does not have class method .call defined

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

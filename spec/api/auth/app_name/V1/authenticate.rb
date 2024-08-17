# frozen_string_literal: true

require_relative '../../../../support/command_callable'

module Api
  module Auth
    module AppName
      module V1
        # This is a custom command that does not prepend SimpleCommand.
        class Authenticate
          prepend CommandCallable

          def initialize(params = {})
            @username = params[:username]
            @password = params[:password]
          end

          def call
            execute
          end

          private

          attr_accessor :username, :password

          def execute
            return true if username == :username && password == :password

            false
          end
        end
      end
    end
  end
end

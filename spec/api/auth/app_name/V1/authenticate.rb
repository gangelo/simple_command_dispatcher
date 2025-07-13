# frozen_string_literal: true

module Api
  module Auth
    module AppName
      module V1
        class Authenticate
          prepend SimpleCommandDispatcher::Commands::CommandCallable

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
            username == :username && password == :password
          end
        end
      end
    end
  end
end

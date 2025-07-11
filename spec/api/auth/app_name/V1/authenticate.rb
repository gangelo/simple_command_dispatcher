# frozen_string_literal: true

require_relative '../../../../support/command_callable'

module Api
  module Auth
    module AppName
      module V1
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
            username == :username && password == :password
          end
        end
      end
    end
  end
end

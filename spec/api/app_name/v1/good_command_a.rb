# frozen_string_literal: true

module Api
  module AppName
    module V1
      class GoodCommandA
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def call
          execute
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

# frozen_string_literal: true

module Api
  module AppName
    module V1
      class GoodCommandB
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def initialize(params = {})
          @param1 = params[:param1]
          @param2 = params[:param2]
          @param3 = params[:param3]
        end

        def call
          execute
        end

        private

        attr_accessor :param1, :param2, :param3

        def execute
          return true if param1 == :param1 && param2 == :param2 && param3 == :param3

          errors.add :invalid_parameters, 'Parameters are invalid'

          nil
        end
      end
    end
  end
end

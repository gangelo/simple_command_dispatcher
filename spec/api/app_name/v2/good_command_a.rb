# frozen_string_literal: true

require_relative '../../../support/command_callable'

module Api
  module AppName
    module V2
      class GoodCommandA
        prepend CommandCallable

        def initialize(param1, param2, param3, **_kwargs)
          @param1 = param1
          @param2 = param2
          @param3 = param3
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

# frozen_string_literal: true

module SimpleCommandDispatcher
  module Errors
    # This error is raised when a command class constant is not found or invalid.
    class Errors::InvalidClassConstantError < StandardError
      def initialize(constantized_class_string, error_message)
        super("\"#{constantized_class_string}\" is not a valid class constant. Error message: \"#{error_message}\".")
      end
    end
  end
end

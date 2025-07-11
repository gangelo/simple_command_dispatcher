# frozen_string_literal: true

module SimpleCommandDispatcher
  module Errors
    # This error is raised when a command class constant is not found or invalid.
    class InvalidClassConstantError < StandardError
      # Initializes a new InvalidClassConstantError
      #
      # @param constantized_class_string [String] the class string that failed to constantize
      # @param error_message [String] the underlying error message
      def initialize(constantized_class_string, error_message)
        super("\"#{constantized_class_string}\" is not a valid class constant. Error message: \"#{error_message}\".")
      end
    end
  end
end

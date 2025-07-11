# frozen_string_literal: true

module SimpleCommandDispatcher
  module Errors
    # This error is raised when a required class method is missing on the command class.
    class RequiredClassMethodMissingError < StandardError
      # Initializes a new RequiredClassMethodMissingError
      #
      # @param command_class_constant [Class] the command class that is missing the required method
      def initialize(command_class_constant)
        super("Class \"#{command_class_constant}\" does not respond_to? class method \"call\".")
      end
    end
  end
end

# frozen_string_literal: true

module SimpleCommandDispatcher
  module Errors
    # This error is raised when a required class method is missing on the command class.
    class Errors::RequiredClassMethodMissingError < StandardError
      def initialize(command_class_constant)
        super("Class \"#{command_class_constant}\" does not respond_to? class method \"call\".")
      end
    end
  end
end

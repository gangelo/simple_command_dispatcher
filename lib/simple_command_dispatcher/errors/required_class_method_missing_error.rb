# frozen_string_literal: true

module SimpleCommand
  module Dispatcher
    # This error is raised when a required class method is missing on the command class.
    class RequiredClassMethodMissingError < StandardError
      def initialize(command_class_constant)
        super("Class \"#{command_class_constant}\" does not respond_to? class method \"call\".")
      end
    end
  end
end

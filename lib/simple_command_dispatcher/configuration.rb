# frozen_string_literal: true

module SimpleCommand
  module Dispatcher
    # Gem configuration settings class. Use this class to configure this gem.
    #
    # To configure this gem in your application, simply add the following code in your application and set the
    # appropriate configuration settings.
    #
    # @example
    #
    #    SimpleCommand::Dispatcher.configure do |config|
    #       config.allow_custom_commands = true
    #    end
    #
    class Configuration
      # Gets/sets the *allow_custom_commands* configuration setting (defaults to false).
      # If this setting is set to *false*, only command classes that prepend the *SimpleCommand* module
      # will be considered acceptable to run, all other command classes will fail to run. If this
      # setting is set to *true*, any command class will be considered acceptable to run, regardless of
      # whether or not the class prepends the *SimpleCommand* module.
      #
      # For information about the simple_command gem, visit {https://rubygems.org/gems/simple_command}
      #
      # @return [Boolean] the value.
      #
      attr_accessor :allow_custom_commands

      def initialize
        # The default is to use any command that exposes a ::call class method.
        reset
      end

      # Resets the configuration to use the default values.
      #
      # @return [nil] returns nil.
      #
      def reset
        @allow_custom_commands = false
        nil
      end
    end
  end
end

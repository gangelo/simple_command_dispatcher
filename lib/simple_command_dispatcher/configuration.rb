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
      # TODO: Add configuration options here.
      # attr_accessor :some_config_option

      def initialize
        reset
      end

      # Resets the configuration to use the default values.
      #
      # @return [nil] returns nil.
      #
      def reset
        # TODO: Reset configuration to default values here.
        # @some_config_option = false
        nil
      end
    end
  end
end

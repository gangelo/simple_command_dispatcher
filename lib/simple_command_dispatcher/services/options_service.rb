# frozen_string_literal: true

module SimpleCommandDispatcher
  module Services
    # Handles options for command execution and ensures proper initialization.
    #
    # @example
    #   options = OptionsService.new(options: { pretend: true })
    #   options.pretend? # => true
    class OptionsService
      # Default options for command execution
      DEFAULT_OPTIONS = {
        pretend: false
      }.freeze

      # Initializes the options service with the provided options merged with defaults.
      #
      # @param options [Hash] custom options
      # @option options [Boolean] :pretend (false) enables debug logging when true
      def initialize(options: {})
        @options = DEFAULT_OPTIONS.merge(options)
      end

      # Returns true if pretend mode is enabled.
      # When enabled, debug logging will show command execution flow.
      #
      # @return [Boolean] true if pretend mode is enabled
      def pretend?
        options[:pretend]
      end

      private

      attr_reader :options
    end
  end
end

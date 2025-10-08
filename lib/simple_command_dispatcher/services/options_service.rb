# frozen_string_literal: true

module SimpleCommandDispatcher
  module Services
    # Handles options for command execution and ensures proper initialization.
    #
    # @example
    #   options = OptionsService.new(options: { debug: true })
    #   options.debug? # => true
    class OptionsService
      # Default options for command execution
      DEFAULT_OPTIONS = {
        debug: false
      }.freeze

      # Initializes the options service with the provided options merged with defaults.
      #
      # @param options [Hash] custom options
      # @option options [Boolean] :debug (false) enables debug logging when true
      def initialize(options: {})
        @options = DEFAULT_OPTIONS.merge(options)
      end

      # Returns true if debug mode is enabled.
      # When enabled, debug logging will show command execution flow.
      #
      # @return [Boolean] true if debug mode is enabled
      def debug?
        options[:debug]
      end

      private

      attr_reader :options
    end
  end
end

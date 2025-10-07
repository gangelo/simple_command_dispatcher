# frozen_string_literal: true

module SimpleCommandDispatcher
  module Services
    # Handles options and ensures that they are initialized and valid before accessing them.
    class OptionsService
      DEFAULT_OPTIONS = {
        pretend: false
      }.freeze

      def initialize(options: {})
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def pretend?
        options[:pretend]
      end

      private

      attr_reader :options
    end
  end
end

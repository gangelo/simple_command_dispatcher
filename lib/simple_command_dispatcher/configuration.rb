# frozen_string_literal: true

# This is the configuration for SimpleCommandDispatcher.
module SimpleCommandDispatcher
  class << self
    # Configures SimpleCommandDispatcher by yielding the configuration object to the block.
    #
    # @yield [Configuration] yields the configuration object to the block
    # @return [Configuration] returns the configuration object
    #
    # @example
    #
    # SimpleCommandDispatcher.configure do |config|
    #  config.logger = Rails.logger
    # end
    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?

      configuration
    end

    # Returns the configuration object, initializing it if necessary
    #
    # @return [Configuration] the configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    private

    attr_writer :configuration
  end

  # This class encapsulates the configuration properties for this gem and
  # provides methods and attributes that allow for management of the same.
  class Configuration
    attr_accessor :logger

    # Initializes a new Configuration instance with default values
    def initialize
      reset
    end

    # Resets all configuration attributes to their default values
    def reset
      @logger = default_logger
    end

    private

    def default_logger
      if defined?(Rails) && Rails.respond_to?(:logger)
        Rails.logger
      else
        require 'logger'
        ::Logger.new($stdout)
      end
    end
  end
end

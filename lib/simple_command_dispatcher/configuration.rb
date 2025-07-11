# frozen_string_literal: true

# This is the configuration for SimpleCommandDispatcher.
module SimpleCommandDispatcher
  class << self
    attr_reader :configuration

    # Configures SimpleCommandDispatcher by yielding the configuration object to the block.
    #
    # @yield [Configuration] yields the configuration object to the block
    # @return [Configuration] returns the configuration object
    #
    # @example
    #
    # SimpleCommandDispatcher.configure do |config|
    #  config.some_option = 'some value'
    # end
    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?

      configuration
    end

    private

    attr_writer :configuration
  end

  # This class encapsulates the configuration properties for this gem and
  # provides methods and attributes that allow for management of the same.
  class Configuration
    # TODO: Add attr_xxx here

    # Initializes a new Configuration instance with default values
    def initialize
      reset
    end

    # Resets all configuration attributes to their default values
    def reset
      # TODO: Reset our attributes here e.g. @attr = nil
    end
  end
end

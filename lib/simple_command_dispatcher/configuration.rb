# frozen_string_literal: true

# This is the configuration for SimpleCommandDispatcher.
module SimpleCommandDispatcher
  class << self
    attr_reader :configuration

    # Example:
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

    def initialize
      reset
    end

    def reset
      # TODO: Reset our attributes here e.g. @attr = nil
    end
  end
end

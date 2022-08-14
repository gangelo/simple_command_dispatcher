# frozen_string_literal: true

require_relative 'configuration'

module SimpleCommand
  module Dispatcher
    class << self
      attr_writer :configuration
      end

    # Returns the application configuration object.
    #
    # @return [Configuration] the application Configuration object.
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end

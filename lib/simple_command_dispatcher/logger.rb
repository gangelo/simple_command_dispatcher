# frozen_string_literal: true

module SimpleCommandDispatcher
  # Provides logging functionality for SimpleCommandDispatcher.
  # Supports configuration to use Rails logger or custom loggers.
  module Logger
    private

    def log_debug(string)
      logger.debug(string) if logger.respond_to?(:debug)
    end

    def log_error(string)
      logger.error(string) if logger.respond_to?(:error)
    end

    def logger
      SimpleCommandDispatcher.configuration.logger
    end
  end
end

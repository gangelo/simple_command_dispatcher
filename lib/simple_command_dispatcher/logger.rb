# frozen_string_literal: true

# This module will eventually output to a configured stream, so
# that Rails apps can log to the rails logger.
module Logger
  private

  def log_debug(string)
    $stdout.puts string
  end

  def log_error(string)
    warn string
  end
end

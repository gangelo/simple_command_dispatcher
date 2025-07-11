# frozen_string_literal: true

module SimpleCommandDispatcher
  module Helpers
    module TrimAll
      # Removes all whitespace from the given string, including Unicode whitespace
      #
      # @param string [String] the string to remove whitespace from
      # @return [String] the string with all whitespace removed
      def trim_all(string)
        # Using Unicode property \p{Space} to match all Unicode whitespace characters
        string.gsub(/\p{Space}+/, '')
      end
    end
  end
end

# frozen_string_literal: true

module SimpleCommandDispatcher
  module Helpers
    module TrimAll
      def trim_all(string)
        string.gsub(/\s+/, '')
      end
    end
  end
end

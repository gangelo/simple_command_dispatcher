# frozen_string_literal: true

require_relative 'trim_all'

module SimpleCommandDispatcher
  module Helpers
    module Camelize
      include TrimAll

      # Transforms a route into a module string
      #
      # @return [String] the camelized token.
      #
      # @example
      #
      #   camelize("/api/app/auth/v1") # => "Api::App::Auth::V1"
      #   camelize("/api/app_name/auth/v1") # => "Api::AppName::Auth::V1"
      #
      def camelize(token)
        raise ArgumentError, 'Token is not a String' unless token.instance_of? String

        trim_all(token.titlecase.camelize.sub(/^:*/, '')) unless token.empty?
      end
    end
  end
end

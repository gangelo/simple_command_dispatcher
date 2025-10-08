# frozen_string_literal: true

require_relative 'trim_all'

module SimpleCommandDispatcher
  module Helpers
    module Camelize
      include TrimAll

      # Transforms a RESTful route into a Ruby constant string for instantiation
      #
      # @param token [String] the route path to be camelized
      # @return [String] the camelized constant name
      #
      # @example
      #
      #   camelize("/api/users/v1") # => "Api::Users::V1"
      #   # Then: Api::Users::V1.new.call
      #
      def camelize(token)
        raise ArgumentError, 'Token is not a String' unless token.instance_of? String

        return if token.empty?

        # For RESTful paths → Ruby constants, use Rails' proven methods
        # They're fast, reliable, and handle edge cases that matter for constants
        result = trim_all(token)
          .gsub(%r{[/\-.\s:]+}, '/') # Normalize separators to /
          .split('/')                                    # Split into path segments
          .reject(&:empty?)                              # Remove empty segments
          .map { |segment| segment.underscore.camelize } # Rails camelization
          .join('::')                                    # Join as Ruby namespace

        result.empty? ? '' : result
      end
    end
  end
end

# Usage example:
# "/api/user_sessions/v1" → "Api::UserSessions::V1"
#
# Then in your dispatcher:
# constant_name = camelize(request.path)
# command_class = Object.const_get(constant_name)
# command_class.new.call

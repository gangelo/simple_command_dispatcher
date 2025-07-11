# frozen_string_literal: true

require_relative '../helpers/camelize'
require_relative '../helpers/trim_all'

module SimpleCommandDispatcher
  module Services
    # Returns a string of modules that can be subsequently prepended to a class, to create a fully qualified,
    # constantized class.
    #
    # The command_namespace is provided during initialization and can be a Hash, Array, or String.
    #
    # @return [String] a string of modules that can be subsequently prepended to a class, to create a
    #    constantized class.
    #
    # @raise [ArgumentError] if the command_namespace is not of type String, Hash or Array.
    #
    # @example
    #
    #   to_class_modules_string("Api") # => "Api::"
    #   to_class_modules_string([:Api, :AppName, :V1]) # => "Api::AppName::V1::"
    #   to_class_modules_string({ api: :Api, app_name: :AppName, api_version: :V1 }) # => "Api::AppName::V1::"
    #   to_class_modules_string({ api: :api, app_name: :app_name, api_version: :v1 }, { titleize_module: true })
    #      # => "Api::AppName::V1::"
    #
    class CommandNamespaceService
      include Helpers::Camelize
      include Helpers::TrimAll

      def initialize(command_namespace:)
        @command_namespace = command_namespace
      end

      # Handles command module transformations from String, Hash or Array into
      # a fully qualified class modules string (e.g. "A::B::C::").
      def to_class_modules_string
        return '' if command_namespace.blank?

        class_modules_string = join_class_modules_if(command_namespace:)
        class_modules_string = trim_all(camelize(class_modules_string))
        "#{class_modules_string}::"
      end

      private

      attr_reader :command_namespace

      def join_class_modules_if(command_namespace:)
        case command_namespace
        when String
          command_namespace
        when Array
          command_namespace.join('::')
        when Hash
          command_namespace.values.join('::')
        end
      end
    end
  end
end

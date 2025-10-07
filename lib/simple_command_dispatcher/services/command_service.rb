# frozen_string_literal: true

require_relative '../errors'
require_relative '../helpers/camelize'
require_relative 'command_namespace_service'

module SimpleCommandDispatcher
  module Services
    # Handles class and module transformations and instantiation.
    class CommandService
      include Helpers::Camelize

      def initialize(command:, command_namespace: {}, options: {})
        @options = options
        @command = validate_command(command:)
        @command_namespace = validate_command_namespace(command_namespace:)
      end

      # Returns a constantized class (as a Class constant), given the command and command_namespace
      # that were provided during initialization.
      #
      # @return [Class] the class constant.
      #
      # @raise [Errors::InvalidClassConstantError] if the constantized class string cannot be constantized; that is,
      #    if it is not a valid class constant.
      #
      # @example
      #
      #   to_class("Authenticate", "Api") # => Api::Authenticate
      #   to_class(:Authenticate, [:Api, :AppName, :V1]) # => Api::AppName::V1::Authenticate
      #   to_class(:Authenticate, { :api :Api, app_name: :AppName, api_version: :V2 })
      #     # => Api::AppName::V2::Authenticate
      #   to_class("authenticate", { :api :api, app_name: :app_name, api_version: :v1 },
      #     { titleize_class: true, titleize_module: true }) # => Api::AppName::V1::Authenticate
      #
      def to_class
        qualified_class_string = to_qualified_class_string

        if options.pretend?
          log_debug <<~DEBUG
            Command to execute: #{qualified_class_string.inspect}
          DEBUG
        end

        begin
          qualified_class_string.constantize
        rescue StandardError => e
          raise Errors::InvalidClassConstantError.new(qualified_class_string, e.message)
        end
      end

      private

      attr_reader :options, :command, :command_namespace

      # Returns a fully-qualified constantized class (as a string), given the command and command_namespace.
      #
      # @return [String] the fully qualified class, which includes module(s) and class name.
      #
      def to_qualified_class_string
        class_modules_string = CommandNamespaceService.new(command_namespace:).to_class_modules_string
        class_string = to_class_string(command:)
        "#{class_modules_string}#{class_string}"
      end

      # Returns the command as a string after transformations have been applied.
      # The command is automatically camelized/titleized during processing.
      #
      # @param command [Symbol, String] the class name to be transformed.
      #
      # @return [String] the transformed class as a string.
      #
      # @example
      #
      #   to_class_string(command: "MyClass") # => "MyClass"
      #   to_class_string(command: "my_class") # => "MyClass"
      #   to_class_string(command: :MyClass) # => "MyClass"
      #   to_class_string(command: :my_class) # => "MyClass"
      #
      def to_class_string(command:)
        camelize(command)
      end

      # @!visibility public
      #
      # Validates command and returns command as a string after all blanks have been removed using
      # command.gsub(/\s+/, "").
      #
      # @param [Symbol or String] command the class name to be validated. command cannot be empty?
      #
      # @return [String] the validated class as a string with blanks removed.
      #
      # @raise [ArgumentError] if the command is empty? or not of type String or Symbol.
      #
      # @example
      #
      #   validate_command(" My Class ") # => "MyClass"
      #   validate_command(:MyClass) # => "MyClass"
      #
      def validate_command(command:)
        unless command.is_a?(Symbol) || command.is_a?(String)
          raise ArgumentError,
            'command is not a String or Symbol. command must equal the class name of the ' \
            'command to call in the form of a String or Symbol.'
        end

        command = command.to_s.strip

        raise ArgumentError, 'command is empty?' if command.empty?

        command
      end

      # @!visibility public
      #
      # Validates and returns command_namespace.
      #
      # @param [Hash, Array or String] command_namespace the module(s) to be validated.
      #
      # @return [Hash, Array or String] the validated module(s).
      #
      # @raise [ArgumentError] if the command_namespace is not of type String, Hash or Array.
      #
      # @example
      #
      #   validate_command_namespace(" Module ") # => " Module "
      #   validate_command_namespace(:Module) # => :Module
      #   validate_command_namespace("ModuleA::ModuleB") # => "ModuleA::ModuleB"
      #
      def validate_command_namespace(command_namespace:)
        return {} if command_namespace.blank?

        unless valid_command_namespace_type?(command_namespace:)
          raise ArgumentError,
            'Argument command_namespace is not a String, Hash or Array.'
        end

        command_namespace
      end

      def valid_command_namespace_type?(command_namespace:)
        command_namespace.instance_of?(String) ||
          command_namespace.instance_of?(Hash) ||
          command_namespace.instance_of?(Array)
      end
    end
  end
end

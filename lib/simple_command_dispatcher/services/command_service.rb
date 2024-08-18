# frozen_string_literal: true

require_relative '../errors'
require_relative '../helpers/camelize'
require_relative 'command_namespace_service'

module SimpleCommandDispatcher
  module Services
    # Handles class and module transformations and instantiation.
    class CommandService
      include Helpers::Camelize

      def initialize(command:, command_namespace: {})
        @command = validate_command(command:)
        @command_namespace = validate_command_namespace(command_namespace:)
      end

      # Returns a constantized class (as a Class constant), given the command and command_namespace.
      #
      # @param command [Symbol or String] the class name.
      # @param command_namespace [Hash, Array or String] the modules command belongs to.
      # @param options [Hash] the options that determine how command_namespace is transformed.
      # @option options [Boolean] :camelize (false) determines whether or not both command and command_namespace
      #    should be camelized.
      # @option options [Boolean] :titleize (false) determines whether or not both command and command_namespace
      #    should be titleized.
      # @option options [Boolean] :titleize_class (false) determines whether or not command names should be
      #    titleized.
      # @option options [Boolean] :class_camelized (false) determines whether or not command names should be
      #    camelized.
      # @option options [Boolean] :titleize_module (false) determines whether or not command_namespace names
      #    should be titleized.
      # @option options [Boolean] :module_camelized (false) determines whether or not command_namespace names
      #    should be camelized.
      #
      # @return [Class] the class constant. Can be used to call ClassConstant.constantize.
      #
      # @raise [NameError] if the constantized class string cannot be constantized; that is, if it is not
      #    a valid class constant.
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
        qualified_class_string = to_qualified_class_string(command, command_namespace)

        begin
          qualified_class_string.constantize
        rescue StandardError => e
          raise Errors::InvalidClassConstantError.new(qualified_class_string, e.message)
        end
      end

      private

      attr_accessor :command, :command_namespace

      # Returns a fully-qualified constantized class (as a string), given the command and command_namespace.
      #
      # @param [Symbol or String] command the class name.
      # @param [Hash, Array or String] command_namespace the modules command belongs to.
      # @param [Hash] options the options that determine how command_namespace is transformed.
      # @option options [Boolean] :titleize_class (false) Determines whether or not command should be
      #    titleized.
      # @option options [Boolean] :titleize_module (false) Determines whether or not command_namespace
      #    should be titleized.
      #
      # @return [String] the fully qualified class, which includes module(s) and class name.
      #
      # @example
      #
      #   to_qualified_class_string("Authenticate", "Api") # => "Api::Authenticate"
      #   to_qualified_class_string(:Authenticate, [:Api, :AppName, :V1]) # => "Api::AppName::V1::Authenticate"
      #   to_qualified_class_string(:Authenticate, { :api :Api, app_name: :AppName, api_version: :V2 })
      #      # => "Api::AppName::V2::Authenticate"
      #   to_qualified_class_string("authenticate", { :api :api, app_name: :app_name, api_version: :v1 },
      #      { titleize_class: true, titleize_module: true }) # => "Api::AppName::V1::Authenticate"
      #
      def to_qualified_class_string(command, command_namespace)
        class_modules_string = CommandNamespaceService.new(command_namespace:).to_class_modules_string
        class_string = to_class_string(command:)
        "#{class_modules_string}#{class_string}"
      end

      # Returns the command as a string after transformations have been applied.
      #
      # @param [Symbol or String] command the class name to be transformed.
      # @param [Hash] options the options that determine how command will be transformed.
      # @option options [Boolean] :titleize_class (false) Determines whether or not command should be titleized.
      #
      # @return [String] the transformed class as a string.
      #
      # @example
      #
      #   to_class_string("MyClass") # => "MyClass"
      #   to_class_string("myClass", { titleize_class: true }) # => "MyClass"
      #   to_class_string(:MyClass) # => "MyClass"
      #   to_class_string(:myClass, { titleize_class: true }) # => "MyClass"
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
      # @param [Symbol, Array or String] command_namespace the module(s) to be validated.
      #
      # @return [Symbol, Array or String] the validated module(s).
      #
      # @raise [ArgumentError] if the command_namespace is not of type String, Hash or Array.
      #
      # @example
      #
      #   validate_command_namespace(" Module ") # => " Module "
      #   validate_command_namespace(:Module) # => "Module"
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

# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'simple_command_dispatcher/configure'
require 'simple_command_dispatcher/errors'
require 'simple_command_dispatcher/klass_transform'
require 'simple_command_dispatcher/version'

module Kernel
  def eigenclass
    class << self
      self
    end
  end
end

module SimpleCommand
  # Provides a way to call SimpleCommands or your own custom commands in a more dymanic manner.
  #
  # For information about the simple_command gem, visit {https://rubygems.org/gems/simple_command}
  #
  module Dispatcher
    class << self
      # Calls a *Command* given the command name, the modules the command belongs to
      # and the parameters to pass to the command.
      #
      # @param command [Symbol, String] the name of the Command to call.
      #
      # @param command_namespace [Hash, Array] the ruby modules that qualify the Command to call.
      #    When passing a Hash, the Hash keys serve as documentation only.
      #    For example, ['Api', 'AppName', 'V1'] and { :api :Api, app_name: :AppName, api_version: :V1 }
      #    will both produce 'Api::AppName::V1', this string will be prepended to the command to form the Command
      #    to call (e.g. 'Api::AppName::V1::MySimpleCommand' = Api::AppName::V1::MySimpleCommand.call(*request_params)).
      #
      # @param [Hash] options the options that determine how command and command_module are transformed.
      # @option options [Boolean] :camelize (false) determines whether or not both class and module names should be
      #    camelized.
      # @option options [Boolean] :titleize (false) determines whether or not both class and module names should be
      #    titleized.
      # @option options [Boolean] :class_titleize (false) determines whether or not class names should be titleized.
      # @option options [Boolean] :class_camelized (false) determines whether or not class names should be camelized.
      # @option options [Boolean] :module_titleize (false) determines whether or not module names should be titleized.
      # @option options [Boolean] :module_camelized (false) determines whether or not module names should be camelized.
      #
      # @param request_params [Array<Symbol>] the parameters to pass to the call method of the Command. This
      #    parameter is simply passed through to the call method of the Command.
      #
      # @return [Object] the Object returned as a result of calling the Command#call method.
      #
      # @example
      #
      #  # Below call equates to the following:
      #  # Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' })
      #  SimpleCommand::Dispatcher.call(:Authenticate,
      #     { api: :Api, app_name: :Carz4Rent, api_version: :V1 },
      #     { email: 'sam@gmail.com', password: 'AskM3!' } ) # => Command result
      #
      #  # Below equates to the following: Api::Carz4Rent::V2::Authenticate.call('sam@gmail.com', 'AskM3!')
      #  SimpleCommand::Dispatcher.call(:Authenticate,
      #     ['Api', 'Carz4Rent', 'V2'], 'sam@gmail.com', 'AskM3!') # => Command result
      #
      #  # Below equates to the following:
      #  # Api::Auth::JazzMeUp::V1::Authenticate.call('jazz_me@gmail.com', 'JazzM3!')
      #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api::Auth::JazzMeUp', :V1],
      #     'jazz_me@gmail.com', 'JazzM3!') # => Command result
      #
      def call(command:, command_namespace: {}, request_params: nil, options: {})
        # Create a constantized class from our command and command_namespace...
        constantized_class_object = KlassTransform.new(command, command_namespace, options).to_class
        validate_command!(constantized_class_object)

        # We know we have a valid command class object if we get here. All we need to do is call the .call
        # class method, pass the request_params arguments depending on the request_params data type, and
        # return the results.

        if request_params.is_a?(Hash)
          run_command(constantized_class_object, **request_params)
        elsif request_params.is_a?(Array)
          run_command(constantized_class_object, *request_params)
        else
          run_command(constantized_class_object, request_params)
        end
      end

      private

      def validate_command!(constantized_class_object)
        unless constantized_class_object.eigenclass.public_method_defined?(:call)
          raise RequiredClassMethodMissingError, constantized_class_object
        end
      end

      def run_command(klass_constant, *parameters, **keyword_parameters)
        if keyword_parameters.empty?
          klass_constant.call(*parameters)
        else
          klass_constant.call(*parameters, **keyword_parameters)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'core_ext/kernel'
require 'simple_command_dispatcher/commands/command_callable'
require 'simple_command_dispatcher/configuration'
require 'simple_command_dispatcher/errors'
require 'simple_command_dispatcher/logger'
require 'simple_command_dispatcher/services/command_service'
require 'simple_command_dispatcher/services/options_service'
require 'simple_command_dispatcher/version'

module SimpleCommandDispatcher
  extend Logger

  # Provides a way to call your custom commands dynamically.
  #
  class << self
    # Calls a *Command* given the command name, the namespace (modules) the command belongs to
    # and the (request) parameters to pass to the command.
    #
    # @param command [Symbol, String] the name of the Command to call.
    #
    # @param command_namespace [Hash, Array, String] the ruby modules that qualify the Command to call.
    #    When passing a Hash, the Hash keys serve as documentation only.
    #    For example, ['Api', 'AppName', 'V1'], 'Api::AppName::V1', and { :api :Api, app_name: :AppName, api_version: :V1 }
    #    will all produce 'Api::AppName::V1', this string will be prepended to the command to form the Command
    #    to call (e.g. 'Api::AppName::V1::MySimpleCommand' = Api::AppName::V1::MySimpleCommand.call(*request_params)).
    #
    # @param request_params [Hash, Array, Object] the parameters to pass to the call method of the Command. This
    #    parameter is simply passed through to the call method of the Command. Hash parameters are passed as
    #    keyword arguments, Array parameters are passed as positional arguments, and other objects are passed
    #    as a single argument.
    #
    # @param options [Hash] optional configuration for command execution.
    #    Supported options:
    #    - :debug [Boolean] when true, enables debug logging of command execution flow
    #
    # @return [Object] the Object returned as a result of calling the Command#call method.
    #
    # @example
    #
    #  # Below call equates to the following:
    #  # Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' })
    #  SimpleCommandDispatcher.call(command: :Authenticate,
    #     command_namespace: { api: :Api, app_name: :Carz4Rent, api_version: :V1 },
    #     request_params: { email: 'sam@gmail.com', password: 'AskM3!' } ) # => Command result
    #
    #  # Below equates to the following: Api::Carz4Rent::V2::Authenticate.call('sam@gmail.com', 'AskM3!')
    #  SimpleCommandDispatcher.call(command: :Authenticate,
    #     command_namespace: ['Api', 'Carz4Rent', 'V2'],
    #     request_params: ['sam@gmail.com', 'AskM3!']) # => Command result
    #
    #  # Below equates to the following:
    #  # Api::Auth::JazzMeUp::V1::Authenticate.call('jazz_me@gmail.com', 'JazzM3!')
    #  SimpleCommandDispatcher.call(command: :Authenticate,
    #     command_namespace: ['Api::Auth::JazzMeUp', :V1],
    #     request_params: ['jazz_me@gmail.com', 'JazzM3!']) # => Command result
    #
    def call(command:, command_namespace: {}, request_params: nil, options: {})
      @options = Services::OptionsService.new(options:)

      if @options.debug?
        log_debug <<~DEBUG
          Begin dispatching command
            command: #{command.inspect}
            command_namespace: #{command_namespace.inspect}
        DEBUG
      end

      # Create a constantized class from our command and command_namespace...
      constantized_class_object = Services::CommandService.new(command:, command_namespace:, options: @options).to_class

      if @options.debug?
        log_debug <<~DEBUG
          Constantized command: #{constantized_class_object.inspect}
        DEBUG
      end

      validate_command!(constantized_class_object)

      # We know we have a valid command class object if we get here. All we need to do is call the .call
      # class method, pass the request_params arguments depending on the request_params data type, and
      # return the results.

      call_command_results = call_command(constantized_class_object:, request_params:)

      log_debug 'End dispatching command' if @options.debug?

      call_command_results
    end

    private

    attr_reader :options

    def call_command(constantized_class_object:, request_params:)
      if request_params.is_a?(Hash)
        constantized_class_object.call(**request_params)
      elsif request_params.is_a?(Array)
        constantized_class_object.call(*request_params)
      elsif request_params.present?
        constantized_class_object.call(request_params)
      else
        constantized_class_object.call
      end
    end

    def validate_command!(constantized_class_object)
      unless constantized_class_object.eigenclass.public_method_defined?(:call)
        raise Errors::RequiredClassMethodMissingError, constantized_class_object
      end
    end
  end
end

require "simple_command_dispatcher/version"
require "simple_command_dispatcher/klass_transform"
require "simple_command"
require "active_support/core_ext/string/inflections"

require 'simple_command_dispatcher/configuration'
require 'simple_command_dispatcher/configure'

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
         include SimpleCommand::KlassTransform

         public

         # Calls a *SimpleCommand* or *Command* given the command name, the modules the command belongs to and the parameters to pass to the command.
         #
         # @param command [Symbol, String] the name of the SimpleCommand or Command to call.
         #
         # @param command_modules [Hash, Array] the ruby modules that qualify the SimpleCommand to call. When passing a Hash, the Hash 
         #    keys serve as documentation only. For example, ['Api', 'AppName', 'V1'] and { :api :Api, app_name: :AppName, api_version: :V1 }
         #    will both produce 'Api::AppName::V1', this string will be prepended to the command to form the SimpleCommand to call
         #    (e.g. 'Api::AppName::V1::MySimpleCommand' = Api::AppName::V1::MySimpleCommand.call(*command_parameters)).
         #
         # @param [Hash] options the options that determine how command and command_module are transformed.
         # @option options [Boolean] :camelize (false) determines whether or not both class and module names should be camelized.
         # @option options [Boolean] :titleize (false) determines whether or not both class and module names should be titleized.
         # @option options [Boolean] :class_titleize (false) determines whether or not class names should be titleized.
         # @option options [Boolean] :class_camelized (false) determines whether or not class names should be camelized.
         # @option options [Boolean] :module_titleize (false) determines whether or not module names should be titleized.
         # @option options [Boolean] :module_camelized (false) determines whether or not module names should be camelized.
         #
         # @param command_parameters [Array<Symbol>] the parameters to pass to the call method of the SimpleCommand . This parameter is simply
         #    passed through to the call method of the SimpleCommand/Command.
         #
         # @return [SimpleCommand, Object] the SimpleCommand or Object returned as a result of calling the SimpleCommand#call method or the Command#call method respectfully.
         #
         # @example
         #     
         #  # Below call equates to the following: Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' })
         #  SimpleCommand::Dispatcher.call(:Authenticate, { api: :Api, app_name: :Carz4Rent, api_version: :V1 }, 
         #                              { email: 'sam@gmail.com', password: 'AskM3!' } ) # => SimpleCommand result
         #
         #  # Below equates to the following: Api::Carz4Rent::V2::Authenticate.call('sam@gmail.com', 'AskM3!')   
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api', 'Carz4Rent', 'V2'], 'sam@gmail.com', 'AskM3!') # => SimpleCommand result 
         #
         #  # Below equates to the following: Api::Auth::JazzMeUp::V1::Authenticate.call('jazz_me@gmail.com', 'JazzM3!')  
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api::Auth::JazzMeUp', :V1], 'jazz_me@gmail.com', 'JazzM3!') # => SimpleCommand result
         #
         def call(command = "", command_modules = {}, options = {}, *command_parameters)

            # Create a constantized class from our command and command_modules...
            command_class_constant = to_constantized_class(command, command_modules, options)

            # If we're NOT allowing custom commands, make sure we're dealing with a a command class
            # that prepends the SimpleCommand module.
            if !SimpleCommand::Dispatcher.configuration.allow_custom_commands  
               # Calling is_simple_command? returns true if the class pointed to by
               # command_class_constant is a valid SimpleCommand class; that is, 
               # if it prepends module SimpleCommand::ClassMethods.
               if !is_simple_command?(command_class_constant) 
                  raise ArgumentError.new("Class \"#{command_class_constant}\" must prepend module SimpleCommand if Configuration#allow_custom_commands is true.")
               end
            end

            if is_valid_command(command_class_constant)
               # We know we have a valid SimpleCommand; all we need to do is call #call,
               # pass the command_parameter variable arguments to the call, and return the results.
               run_command(command_class_constant, command_parameters)
            else
               raise NameError.new("Class \"#{command_class_constant}\" does not respond_to? method ::call.")
            end
         end

         private

         # Returns true or false depending on whether or not the class constant has a public 
         # class method named ::call defined. Commands that do not have a public class method
         # named ::call, are considered invalid.
         #
         # @param klass_constant [String] a class constant that will be validated to see whether or not the class is a valid command.
         #
         # @return [Boolean] true if klass_constant has a public class method named ::call defined, false otherwise.
         #
         # @!visibility public
         def is_valid_command(klass_constant)
            klass_constant.eigenclass.public_method_defined?(:call)
         end

         # Returns true or false depending on whether or not the class constant prepends module SimpleCommand::ClassMethods.
         #
         # @param klass_constant [String] a class constant that will be validated to see whether or not the class prepends module SimpleCommand::ClassMethods.
         #
         # @return [Boolean] true if klass_constant prepends Module SimpleCommand::ClassMethods, false otherwise.
         #
         # @!visibility public
         def is_simple_command?(klass_constant)
            klass_constant.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end

         # Runs the command given the parameters and returns the result.
         #
         # @param klass_constant [String] a class constant that will be called.
         # @param parameters [Array] an array of parameters to pass to the command that will be called.
         #
         # @return [Object] returns the object (if any) that results from calling the command.
         #
         # @!visibility public
         def run_command(klass_constant, parameters)
            klass_constant.call(*parameters)
         #rescue NameError
         #   raise NameError.new("Class \"#{klass_constant}\" does not respond_to? method ::call.")
         end
      end
   end
end

require "simple_command_dispatcher/version"
require "simple_command_dispatcher/klass_transform"
require "simple_command"
require "active_support/core_ext/string/inflections"

module Kernel
  def eigenclass
    class << self
      self
    end
  end
end

module SimpleCommand
   
   # Provides a way to call SimpleCommand commands in a more dymanic manner.
   #
   # For information about the simple_command gem, visit https://rubygems.org/gems/simple_command
   #
   module Dispatcher
      
      class << self
         include SimpleCommand::KlassTransform

         public

         # Calls a *SimpleCommand* given the command name, the modules the command belongs to and the parameters to pass to the command.
         #
         # @param command [Symbol, String] the name of the SimpleCommand to call.
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
         # @param command_parameters [*] the parameters to pass to the call method of the SimpleCommand. This parameter is simply
         #    passed through to the call method of the SimpleCommand.
         #
         # @return [SimpleCommand] the SimpleCommand returned as a result from calling the SimpleCommand#call method.
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
            simple_command_class_constant = to_constantized_class(command, command_modules, options)

            # Calling is_simple_command? returns true if the class pointed to by
            # simple_command_class_constant is a valid SimpleCommand class; that is, 
            # if it prepends module SimpleCommand::ClassMethods.
            if !is_simple_command?(simple_command_class_constant) 
               raise ArgumentError.new('Class does not prepend module SimpleCommand.')
            end

            # We know we have a valid SimpleCommand; all we need to do is call #call,
            # pass the command_parameter variable arguments to the call, and return the results.
            simple_command_class_constant.call(*command_parameters)
         end

         private

         # @!visibility public
         #
         # Returns true or false depending on whether or not the class constant prepends module SimpleCommand::ClassMethods.
         #
         # @param klass_constant [String] a class constant that will be validated to see whether or not the class prepends module SimpleCommand::ClassMethods.
         #
         # @return [Boolean] true if klass_constant prepends Module SimpleCommand::ClassMethods, false otherwise.
         #
         def is_simple_command?(klass_constant)
            klass_constant.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end
      end
   end
end

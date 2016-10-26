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
   module Dispatcher

      class << self
         include SimpleCommand::KlassTransform

         public

         # Calls a SimpleCommand given the command name, the modules the command belongs to and the parameters to pass to the command.
         #
         # @param [Symbol || String] command the name of the SimpleCommand to call.
         # @param [Hash || Array] command_modules the ruby modules that qualify the SimpleCommand to call. When passing a Hash, the Hash 
         #    keys serve as documentation only. For example, ['Api', 'AppName', 'V1'] and { :api :Api, app_name: :AppName, api_version: :V1 }
         #    will both produce 'Api::AppName::V1', this string will be prepended to the command (see #command) to form the SimpleCommand to call
         #    (e.g. 'Api::AppName::V1::MySimpleCommand' = Api::AppName::V1::MySimpleCommand.call(*command_parameters)).
         # @param [*] command_parameters the parameters to pass to the call method of the SimpleCommand (See #command). This parameter is simply
         #    passed through to the call method of the SimpleCommand (See #command).
         #
         # @return [SimpleCommand] the SimpleCommand returned as a result from calling the SimpleCommand#call method.
         #
         # @example
         #
         #  # The below call equates to the following: Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' }).
         #  # This example passes #command_modules and #command_parameters as Hash objects.
         #  SimpleCommand::Dispatcher.call(:Authenticate, { api: :Api, app_name: :Carz4Rent, api_version: :V1 }, 
         #                              { email: 'sam@gmail.com', password: 'AskM3!' } ) # => SimpleCommand result
         #
         #  # The below call equates to the following: Api::Carz4Rent::V2::Authenticate.call('sam@gmail.com', 'AskM3!')    
         #  # This example passes #command_modules as an Array, and #command_parameters as individual arguments, and calls version 2 (:V2)
         #  # of the previous example's Authenticate command.
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api', 'Carz4Rent', 'V2'], 'sam@gmail.com', 'AskM3!') # => SimpleCommand result 
         #
         #  # The below call equates to the following: Api::Auth::JazzMeUp::V1::Authenticate.call('jazz_me@gmail.com', 'JazzM3!')  
         #  # This example passes #command_modules as an Array, combining 'Api::Auth::JazzMeUp' as a string, and :V1 (version) as a Symbol as well
         #  # as passing #command_parameters as a Hash object.  
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api::Auth::JazzMeUp', :V1], 'jazz_me@gmail.com', 'JazzM3!') # => SimpleCommand result
         def call(command = "", command_modules = {}, options = {}, *command_parameters)
            # Transform our command modules (e.g. [:Api, :Auth, :V1, etc...]) into a valid module
            # hierarchy ("Api::Auth::V1::etc..."") that qualifies the commmand to be called.
            

            # This line of code simply contatenates the command modules and the command to form
            # a valid SimpleCommand constant that we will use to execute (e.g 'Api::Auth::V1::MySimpleCommand').

     
            # See if our SimpleCommand is a valid constant. Calling Object.const_get simply
            # lets us know whether or not the transformed_command is a valid constant
            # within the module hierarchy. If it is, we know it is tentatively a valid
            # SimpleCommand.
            #simple_command_class_constant = Object.const_get(transformed_command)
            simple_command_class_constant = to_constantized_class(command, command_modules, options)

            p simple_command_class_constant

            # Calling valid_simple_command? returns true if the class pointed to by
            # simple_command_class_constant is a valid SimpleCommand class; that is, 
            # if it prepends module SimpleCommand::ClassMethods.
            if !valid_simple_command?(simple_command_class_constant) 
               raise ArgumentError.new('Class does not prepend module SimpleCommand.')
            end

            # We know we have a valid SimpleCommand; all we need to do is call #call,
            # pass the command_parameter variable arguments to the call, and return
            # the results.
            simple_command_class_constant.call(*command_parameters)
         end

         private

         # Returns true or false depending on whether or not #command prepends Module SimpleCommand::ClassMethods.
         #
         # @param [String] klass_constant the constant representation of the alleged SimpleCommand to interrogate.
         #
         # @return [Boolean] true if #klass_constant prepends Module SimpleCommand::ClassMethods, false otherwise.
         def valid_simple_command?(klass_constant)
            klass_constant.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end
      end
   end
end

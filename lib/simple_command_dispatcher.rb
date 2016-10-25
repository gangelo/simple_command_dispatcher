require "simple_command_dispatcher/version"
require "simple_command"

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
         public

         # Returns the SimpleCommand object called.
         #
         # @param [Symbol || String] command the name of the SimpleCommand to call.
         #
         # @param [Hash || Array] command_qualifiers the ruby modules that qualify the SimpleCommand to call. When passing a Hash, the Hash 
         #    keys serve as documentation only. For example, ['Api', 'AppName', 'V1'] and { :api :Api, app_name: :AppName, api_version: :V1 }
         #    will both produce 'Api::AppName::V1', this string will be prepended to the command (see #command) to form the SimpleCommand to call
         #    (e.g. 'Api::AppName::V1::MySimpleCommand' = Api::AppName::V1::MySimpleCommand.call(*command_parameters)).
         #
         # @param [*] *command_parameters the parameters to pass to the call method of the SimpleCommand (See #command). This parameter is simply
         #    passed through to the call method of the SimpleCommand (See #command).
         #
         # @example Usage
         #
         #  # The below call equates to the following: Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' }).
         #  # This example passes #command_qualifiers and #command_parameters as Hash objects.
         #  SimpleCommand::Dispatcher.call(:Authenticate, { api: :Api, app_name: :Carz4Rent, api_version: :V1 }, 
         #                              { email: 'sam@gmail.com', password: 'AskM3!' } ) # => SimpleCommand result
         #
         #  # The below call equates to the following: Api::Carz4Rent::V2::Authenticate.call('sam@gmail.com', 'AskM3!')    
         #  # This example passes #command_qualifiers as an Array, and #command_parameters as individual arguments, and calls version 2 (:V2)
         #  # of the previous example's Authenticate command.
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api', 'Carz4Rent', 'V2'], 'sam@gmail.com', 'AskM3!') # => SimpleCommand result 
         #
         #  # The below call equates to the following: Api::Auth::JazzMeUp::V1::Authenticate.call('jazz_me@gmail.com', 'JazzM3!')  
         #  # This example passes #command_qualifiers as an Array, combining 'Api::Auth::JazzMeUp' as a string, and :V1 (version) as a Symbol as well
         #  # as passing #command_parameters as a Hash object.  
         #  SimpleCommand::Dispatcher.call(:Authenticate, ['Api::Auth::JazzMeUp', :V1], 'jazz_me@gmail.com', 'JazzM3!') # => SimpleCommand result
         #
         # @return [SimpleCommand result] the SimpleCommand result.
         def call(command, command_qualifiers = {}, *command_parameters)
            # Check our parameters...
            if command.nil?
               raise ArgumentError.new('Parameter [command] is nil.')
            end

            if !(command.is_a?(Symbol) || command.is_a?(String))
               raise ArgumentError.new('Parameter [command] is not a String or Symbol. Parameter [command] must equal the SimpleCommand to call of type String or Symbol.')
            end

            command = "#{get_qualifier(command_qualifiers)}#{command}"
            # p command
            
            begin
               # See if our SimpleCommand is a valid constant.
               command_object = Object.const_get(command)
            rescue
               raise NameError.new('Parameter [command] is not a valid constant. Parameter [command] must be a valid (SimpleCommand) constant within the specified module(s)')
            end

            if !includes_simple_command(command_object) 
               raise ArgumentError.new('Parameter [command] does not prepend module SimpleCommand. Using duck typing instead...')
            end

            command_object.call(*command_parameters)
         end

         private

         def includes_simple_command(klass_object)
            klass_object.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end

         def get_qualifier(command_qualifiers)
            if command_qualifiers.instance_of?(Array)
               "#{command_qualifiers.join('::')}::"
            else
               qualifier = ''
               Hash[command_qualifiers.to_a.reverse].each do | key, value |
                  qualifier = "#{value.to_s}::#{qualifier}"
               end
               qualifier
            end
         end
      end
   end
end



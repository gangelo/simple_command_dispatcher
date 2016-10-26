require "simple_command_dispatcher/version"
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
            # Let's just make sure we're not dealing with annoying nil parameters.
            command ||= ""
            command_modules ||= {}
            options = {} unless options.instance_of? Hash
            options = { titleize_command: false, titleize_command_modules: false }.merge(options)

            # Check our parameters...
            if !(command.is_a?(Symbol) || command.is_a?(String))
               raise ArgumentError.new('Command is not a String or Symbol. Command must equal the name of the SimpleCommand to call in the form of a String or Symbol.')
            end

            command = command.to_s.trim_all

            if command.nil? || command.empty?
               raise ArgumentError.new('Command is nil or empty?')
            end

            # Transform our command modules (e.g. [:Api, :Auth, :V1, etc...]) into a valid module
            # hierarchy ("Api::Auth::V1::etc..."") that qualifies the commmand to be called.
            transformed_command_modules = transform_modules(command_modules, options)
            transformed_command_name = transform_command(command, options)   

            # This line of code simply contatenates the command modules and the command to form
            # a valid SimpleCommand constant that we will use to execute (e.g 'Api::Auth::V1::MySimpleCommand').
            transformed_command = "#{transformed_command_modules}#{transformed_command_name}"

            p transformed_command
            
            begin
               # See if our SimpleCommand is a valid constant. Calling Object.const_get simply
               # lets us know whether or not the transformed_command is a valid constant
               # within the module hierarchy. If it is, we know it is tentatively a valid
               # SimpleCommand.
               #simple_command_class_constant = Object.const_get(transformed_command)
               simple_command_class_constant = transformed_command.constantize
            rescue
               raise NameError.new("\"#{transformed_command}\" is not a valid SimpleCommand command.")
            end

            # Calling valid_simple_command? returns true if the class pointed to by
            # simple_command_class_constant is a valid SimpleCommand class; that is, 
            # if it prepends module SimpleCommand::ClassMethods.
            if !valid_simple_command?(simple_command_class_constant) 
               raise ArgumentError.new('Command does not prepend module SimpleCommand. Using duck typing instead...')
            end

            # We know we have a valid SimpleCommand; all we need to do is call #call,
            # pass the command_parameter variable arguments to the call, and return
            # the results.
            simple_command_class_constant.call(*command_parameters)
         end

         private

         def transform_command(command, options)
            command = command.to_s unless command.instance_of? String
            if options[:titleize_command]
               command = command.titleize
            end
            command
         end

         # Returns true or false depending on whether or not #command prepends Module SimpleCommand::ClassMethods.
         #
         # @param [String] klass_constant the constant representation of the alleged SimpleCommand to interrogate.
         #
         # @return [Boolean] true if #klass_constant prepends Module SimpleCommand::ClassMethods, false otherwise.
         def valid_simple_command?(klass_constant)
            klass_constant.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end

         # Returns the #command Modules qualifier given the #command_modules.
         #
         # @param [String or Hash] command_modules the #command_modules provided to #call.
         # @param [Hash] options the #options provided to #call.
         #
         # @return [String] the fully qualified modules that will be prepended to #command,
         # in order to create a valid SimpleCommand constant class to call.
         #
         # @example
         #
         #  SimpleCommand::Dispatcher.transform_modules([:Api, :AppName, :V1]) # => "Api::AppName::V1::"
         #  SimpleCommand::Dispatcher.transform_modules({ :api :Api, app_name: :AppName, api_version: :V1 }) # => "Api::AppName::V1::"
         def transform_modules(command_modules, options)
            qualifier = ''
            if !command_modules.empty?
               if command_modules.instance_of?(Array)
                  qualifier = "#{command_modules.join('::')}"
               else
                  qualifier = ''
                  command_modules.to_a.each_with_index.map { | value, index | 
                     qualifier = index == 0 ? value[1].to_s : "#{qualifier}::#{value[1]}"
                  }
               end
               qualifier = qualifier.split('::').map(&:titleize).join('::') if options[:titleize_command_modules]
               qualifier = qualifier.trim_all
               qualifier = "#{qualifier}::" unless qualifier.empty?
            end
            qualifier
         end
      end
   end
end

require "simple_command_dispatcher/version"
require "simple_command"
require "logger"

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
         # @param [Symbol || String] command (or [String]) the name of the SimpleCommand to call.
         # @param [Object] command_params the parameters to pass to the call method of the SimpleCommand (See #command). This parameter is simply
         #    passed through to the call method of the SimpleCommand (See #command).
         # @param [Hash] command_qualifiers the ruby modules that qualify the SimpleCommand to call.
         #
         # @example Usage
         #
         #  # The below call equates to the following: Api::Carz4Rent::V1::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' })
         #  SimpleCommand::Dispatcher.call(:Authenticate, { email: 'sam@gmail.com', password: 'AskM3!' }, 
         #               { api: :Api, app_name: :Carz4Rent, api_version: :V1 } ) # => SimpleCommand result
         #
         #  # The below call equates to the following: Api::Carz4Rent::V2::Authenticate.call({ email: 'sam@gmail.com', password: 'AskM3!' })    
         #  SimpleCommand::Dispatcher.call(:Authenticate, { email: 'sam@gmail.com', password: 'AskM3!' }, 
         #               { api: :Api, app_name: :Carz4Rent, api_version: :V2 } )  # => SimpleCommand result
         #     
         #
         # @return [SimpleCommand result] the SimpleCommand result.
         def call(command, command_params = nil, command_qualifiers = {})
            logger = Logger.new(STDOUT)

            # Check our parameters...

            # [command]
            if command.nil?
               raise ArgumentError.new('Parameter [command] is nil.')
            end

            if !(command.is_a?(Symbol) || command.is_a?(String))
               raise ArgumentError.new('Parameter [command] is not a String or Symbol. Parameter [command] must equal the SimpleCommand to call of type String or Symbol.')
            end

            Hash[command_qualifiers.to_a.reverse].each do | key, value |
               command = "#{value.to_s}::#{command}"
            end
            
            begin
               # See if our SimpleCommand is a valid constant.
               command_object = Object.const_get(command)
            rescue
               raise NameError.new('Parameter [command] is not a valid constant. Parameter [command] must be a valid (SimpleCommand) constant within the specified module(s)')
            end

            if !includes_simple_command(command_object) 
               raise ArgumentError.new('Parameter [command] does not prepend module SimpleCommand. Using duck typing instead...')
            end

            command_object.call(command_params)
         end

         private

         def includes_simple_command(klass_object)
            klass_object.eigenclass.included_modules.include? SimpleCommand::ClassMethods
         end
      end
   end
end




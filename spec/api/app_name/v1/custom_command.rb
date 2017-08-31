module Api
   module AppName
         module V1

            # This is a custom command that does not prepend SimpleCommand.
            class CustomCommand

               def self.call(*args)
                  command = self.new(*args)
                  if command
                     command.send(:execute)
                  else
                     false
                  end
               end

               private 

               def initialize(params = {})
                  @param1 = params[:param1]
               end

               attr_accessor :param1

               def execute
                  if (param1 == :param1)
                     return true
                  end

                  return false
               end
            end

      end
   end
end
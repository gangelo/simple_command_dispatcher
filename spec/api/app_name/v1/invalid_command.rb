module Api
   module AppName
         module V1

            class InvalidCommand
               # Doess not extend SimpleCommand.
               # prepend SimpleCommand

               def initialize(params = {})
                  @param1 = params[:param1]
                  @param2 = params[:param2]
                  @param3 = params[:param3]
               end

               def call
                  execute
               end

               private

               attr_accessor :param1, :param2, :param3

               def execute
                  if (param1 == :param1 && param2 == :param2 && param3 == :param3)
                     return true
                  end

                  return false
               end
            end

      end
   end
end
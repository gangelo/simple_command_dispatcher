require "simple_command"

module Api
   module AppName
         module V2

            class TestCommand
               prepend SimpleCommand

               def initialize(param1, param2, param3)
                  @param1 = param1
                  @param2 = param2
                  @param3 = param3
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

                  errors.add :invalid_parameters, 'Parameters are invalid'

                  nil
               end
            end

      end
   end
end
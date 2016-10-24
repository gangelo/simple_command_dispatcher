require "spec_helper"

describe SimpleCommandDispatcher do
  #it "has a version number" do
  #  expect(SimpleCommandDispatcher::VERSION).not_to be nil
  #end

  it "should return success? if successful" do
   command = SimpleCommand::Dispatcher.call(:TestCommand, { param1: :param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 })
    expect(command.success?).to eq(true)
  end

  it "should return failure? if unsuccessful" do
   command = SimpleCommand::Dispatcher.call(:TestCommand, { param1: :bad_param_param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 })
    expect(command.failure?).to eq(true)
  end

   context '[command] Parameter' do

      it "should throw an exception if parameter [command] is nil" do
         expect { SimpleCommand::Dispatcher.call(nil, { param1: :bad_param_param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 }) }
            .to raise_error(ArgumentError, 'Parameter [command] is nil.')
      end

      it "should throw an exception if parameter [command] is not a Symbol or a String" do
         expect { SimpleCommand::Dispatcher.call([], { param1: :bad_param_param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 }) }
            .to raise_error(ArgumentError, 'Parameter [command] is not a String or Symbol. Parameter [command] must equal the SimpleCommand to call of type String or Symbol.')
      end

      it "should throw an exception if parameter [command] is not a valid constant" do
         expect { SimpleCommand::Dispatcher.call(:NameErrorCommand, { param1: :param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 }) }
            .to raise_error(NameError, 'Parameter [command] is not a valid constant. Parameter [command] must be a valid (SimpleCommand) constant within the specified module(s)')
      end

      it "should throw an exception if parameter [command] does not prepend module SimpleCommand" do
         expect { SimpleCommand::Dispatcher.call(:InvalidCommand, { param1: :bad_param_param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 }) }
            .to raise_error(ArgumentError, 'Parameter [command] does not prepend module SimpleCommand. Using duck typing instead...')
      end

      it "should return success? if parameter [command] is a String" do
         command = SimpleCommand::Dispatcher.call('TestCommand', { param1: :param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if parameter [command] is a Symbol" do
         command = SimpleCommand::Dispatcher.call(:TestCommand, { param1: :param1, param2: :param2, param3: :param3 }, { api: :Api, app_name: :AppName, api_version: :V1 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if command_qualifiers are combined as strings" do
         command = SimpleCommand::Dispatcher.call(:TestCommand, { param1: :param1, param2: :param2, param3: :param3 }, { api_qualifier: 'Api::AppName', version: :V1 })
         expect(command.success?).to eq(true)
      end

       it "should return success? if [command] contains api qualifiers and [command_qualifiers] are nil" do
         command = SimpleCommand::Dispatcher.call('Api::AppName::V1::TestCommand', { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

   end

   #contect '[command_parameters]'
end

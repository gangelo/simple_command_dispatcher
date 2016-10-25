require "spec_helper"

describe SimpleCommand::Dispatcher do
  it "has a version number" do
    expect(SimpleCommand::Dispatcher::VERSION).not_to be nil
  end

  it "should return success? if successful" do
   command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :param1, param2: :param2, param3: :param3 })
    expect(command.success?).to eq(true)
  end

  it "should return failure? if unsuccessful" do
   command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :bad_param_param1, param2: :param2, param3: :param3 })
    expect(command.failure?).to eq(true)
  end

   context '[command] Parameter' do

      it "should throw an exception if parameter [command] is nil" do
         expect { SimpleCommand::Dispatcher.call(nil, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :bad_param_param1, param2: :param2, param3: :param3 }) }
            .to raise_error(ArgumentError, 'Parameter [command] is nil.')
      end

      it "should throw an exception if parameter [command] is not a Symbol or a String" do
         expect { SimpleCommand::Dispatcher.call([], { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :bad_param_param1, param2: :param2, param3: :param3 }) }
            .to raise_error(ArgumentError, 'Parameter [command] is not a String or Symbol. Parameter [command] must equal the SimpleCommand to call of type String or Symbol.')
      end

      it "should throw an exception if parameter [command] is not a valid constant" do
         expect { SimpleCommand::Dispatcher.call(:NameErrorCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :param1, param2: :param2, param3: :param3 }) }
            .to raise_error(NameError, 'Parameter [command] is not a valid constant. Parameter [command] must be a valid (SimpleCommand) constant within the specified module(s)')
      end

      it "should throw an exception if parameter [command] does not prepend module SimpleCommand" do
         expect { SimpleCommand::Dispatcher.call(:InvalidCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :bad_param_param1, param2: :param2, param3: :param3 }) }
            .to raise_error(ArgumentError, 'Parameter [command] does not prepend module SimpleCommand. Using duck typing instead...')
      end

      it "should return success? if parameter [command] is a String" do
         command = SimpleCommand::Dispatcher.call('TestCommand', { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if parameter [command] is a Symbol" do
         command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if command_qualifiers are combined as strings" do
         command = SimpleCommand::Dispatcher.call(:TestCommand, { api_qualifier: 'Api::AppName', version: :V1 }, { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if [command] contains api qualifiers and [command_qualifiers] are nil" do
         command = SimpleCommand::Dispatcher.call('Api::AppName::V1::TestCommand', {}, { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

      it "should return success? if [command] contains api qualifiers and [command_qualifiers] are nil" do
         command = SimpleCommand::Dispatcher.call('Api::AppName::V2::TestCommand', {}, :param1, :param2, :param3)
         expect(command.success?).to eq(true)
      end      

      it "should return success? if [command_qualifiers] are passed as an array" do
         command = SimpleCommand::Dispatcher.call(:TestCommand, [:Api, :AppName, :V1], { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end

      it "should work with commands that are not embedded in amy modules" do
         command = SimpleCommand::Dispatcher.call(:NoQualifiersCommand, nil, { param1: :param1, param2: :param2, param3: :param3 })
         expect(command.success?).to eq(true)
      end
   end

   #contect '[command_parameters]'
end

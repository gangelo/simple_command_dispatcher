# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SimpleCommand::Dispatcher, type: :module do
  before(:each) do
    SimpleCommand::Dispatcher.configure do |config|
      config.allow_custom_commands = false
    end
  end

  it 'has a version number' do
    expect(SimpleCommand::Dispatcher::VERSION).not_to be nil
  end

  describe '.call' do
    context 'when argument :command is an empty string' do
      it 'raises an error' do
        expect do
          SimpleCommand::Dispatcher.call(
            command: '',
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, 'Class is empty?')
      end
    end

    context 'when argument :command is nil' do
      it 'raises an error' do
        expect do
          SimpleCommand::Dispatcher.call(
            command: nil,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, /Class is not a String or Symbol/)
      end
    end

    context 'when argument :command is not a valid command' do
      it 'raises an error' do
        expect do
          SimpleCommand::Dispatcher.call(
            command: :BadCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(NameError, /"Api::AppName::V1::BadCommand" is not a valid class constant/)
      end
    end

    context 'when argument :command_namespace is not a valid command' do
      it 'raises an error' do
        expect do
          SimpleCommand::Dispatcher.call(
            command: :TestCommand,
            command_namespace: [:Api, :BadAppName, :V1],
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(NameError, /"Api::BadAppName::V1::TestCommand" is not a valid class constant/)
      end
    end

    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect do
          SimpleCommand::Dispatcher.call(
            command: :TestCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.not_to raise_error
      end
    end
  end

  context 'command Parameter' do
    it 'should return success? if command_namespace is a string' do
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: 'Api::AppName::V1',
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command] contains api qualifiers and [command_namespace] is nil' do
      command = SimpleCommand::Dispatcher.call(
        command: 'Api::AppName::V1::TestCommand',
        command_namespace: {},
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command] contains api qualifiers and [command_namespace] is nil and request_params are positional arguments' do
      command = SimpleCommand::Dispatcher.call(
        command: 'Api::AppName::V2::TestCommand',
        command_namespace: {},
        request_params: [:param1, :param2, :param3]
      )
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command_namespace] is passed as an array of Symbols' do
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: %i[Api AppName V1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command_namespace] is passed as an array of Strings' do
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: %w[Api AppName V1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end

    it 'should work with commands that are not embedded in any modules' do
      command = SimpleCommand::Dispatcher.call(
        command: :NoQualifiersCommand,
        command_namespace: nil,
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end
  end

  context 'options Parameter' do
    it 'should work if command modules are lower-case and module_titleize option is set to true' do
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: [:api, 'appName', :v1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { module_titleize: true }
      )
      expect(command.success?).to eq(true)
    end

    it 'should work if command module is a route and camelize option is set to true' do
      command = SimpleCommand::Dispatcher.call(
        command: 'test_command',
        command_namespace: '/api/app_name/v1',
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to eq(true)
    end

    it 'should work if command is a route and camelize option is set to true' do
      command = SimpleCommand::Dispatcher.call(
        command: '/api/app_name/v1/test_command',
        command_namespace: '',
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to eq(true)
    end

    it 'should work if command is a route that has a format associated with it and camelize option is set to true' do
      route = '/api/app_name/v1/something_else.json'.split('/').slice(0, 4).join('/')
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: route,
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to eq(true)
    end
  end

  context 'Custom Commands' do
    before(:each) do
      SimpleCommand::Dispatcher.configure do |config|
        config.allow_custom_commands = true
      end
    end

    it 'should work with custom commands' do
      result = SimpleCommand::Dispatcher.call(
        command: :CustomCommand,
        command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
        request_params: { param1: :param1 }
      )
      expect(result).to eq(true)
    end

    it 'should work with SimpleCommand commands when allowing custom commands' do
      command = SimpleCommand::Dispatcher.call(
        command: :TestCommand,
        command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to eq(true)
    end

    it "should raise NameError if doesn't respond_to? ::call" do
      expect do
        SimpleCommand::Dispatcher.call(
          command: :InvalidCustomCommand,
          command_namespace: { api: :Api, app_name: :AppName, api_version: :V2 },
          request_params: { param1: :param1, param2: :param2, param3: :param3 }
        )
      end.to raise_error(NameError, 'Class "Api::AppName::V2::InvalidCustomCommand" does not respond_to? method ::call.')
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SimpleCommand::Dispatcher, type: :module do
  it 'has a version number' do
    expect(SimpleCommand::Dispatcher::VERSION).to_not be_nil
  end

  describe '.call' do
    context 'when keyword argument :command is an empty string' do
      it 'raises an error' do
        expect do
          described_class.call(
            command: '',
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, 'Class is empty?')
      end
    end

    context 'when keyword argument :command is nil' do
      it 'raises an error' do
        expect do
          described_class.call(
            command: nil,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, /Class is not a String or Symbol/)
      end
    end

    context 'when keyword argument :command is not a valid command' do
      it 'raises a InvalidClassConstantError error' do
        expect do
          described_class.call(
            command: :BadCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommand::Dispatcher::InvalidClassConstantError, /"Api::AppName::V1::BadCommand" is not a valid class constant/)
      end
    end

    context 'when keyword argument :command_namespace is not a valid command' do
      it 'raises a InvalidClassConstantError error' do
        expect do
          described_class.call(
            command: :GoodCommandB,
            command_namespace: %i[Api BadAppName V1],
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommand::Dispatcher::InvalidClassConstantError, /"Api::BadAppName::V1::GoodCommandB" is not a valid class constant/)
      end
    end

    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect do
          described_class.call(
            command: :GoodCommandB,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to_not raise_error
      end
    end
  end

  context 'command Parameter' do
    it 'returns success? if command_namespace is a string' do
      command = described_class.call(
        command: :GoodCommandB,
        command_namespace: 'Api::AppName::V1',
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end

    it 'returns success? if [command] contains api qualifiers and [command_namespace] is blank' do
      command = described_class.call(
        command: 'Api::AppName::V1::GoodCommandB',
        command_namespace: {},
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end

    it 'returns success? if [command] contains api qualifiers and [command_namespace] is blank and request_params are positional arguments' do
      command = described_class.call(
        command: 'Api::AppName::V2::GoodCommandA',
        command_namespace: [],
        request_params: %i[param1 param2 param3]
      )
      expect(command.success?).to be(true)
    end

    it 'returns success? if [command_namespace] is passed as an array of Symbols' do
      command = described_class.call(
        command: :GoodCommandB,
        command_namespace: %i[Api AppName V1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end

    it 'returns success? if [command_namespace] is passed as an array of Strings' do
      command = described_class.call(
        command: :GoodCommandB,
        command_namespace: %w[Api AppName V1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end

    it 'works with commands that are not embedded in any modules' do
      command = described_class.call(
        command: :NoQualifiersCommand,
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end
  end

  context 'options Parameter' do
    it 'works if command modules are lower-case and module_titleize option is set to true' do
      command = described_class.call(
        command: :GoodCommandB,
        command_namespace: [:api, 'appName', :v1],
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { module_titleize: true }
      )
      expect(command.success?).to be(true)
    end

    it 'works if command module is a route and camelize option is set to true' do
      command = described_class.call(
        command: 'good_command_b',
        command_namespace: '/api/app_name/v1',
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to be(true)
    end

    it 'works if command is a route and camelize option is set to true' do
      command = described_class.call(
        command: '/api/app_name/v1/good_command_b',
        command_namespace: '',
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to be(true)
    end

    it 'works if command is a route that has a format associated with it and camelize option is set to true' do
      route = '/api/app_name/v1/something_else.json'.split('/').slice(0, 4).join('/')
      command = described_class.call(
        command: :GoodCommandB,
        command_namespace: route,
        request_params: { param1: :param1, param2: :param2, param3: :param3 },
        options: { camelize: true }
      )
      expect(command.success?).to be(true)
    end
  end

  context 'Commands' do
    context 'when the command evaluates to a valid command' do
      it 'does not raise an error' do
        expect do
          described_class.call(
            command: :GoodCommandA,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1 }
          )
        end.to_not raise_error
      end
    end

    context 'when the command evaluates to an invalid command' do
      it "raises a InvalidClassConstantError if doesn't respond_to? class method .call" do
        expect do
          described_class.call(
            command: :InvalidCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V2 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommand::Dispatcher::RequiredClassMethodMissingError, 'Class "Api::AppName::V2::InvalidCommand" does not respond_to? class method "call".')
      end
    end

    context 'when the command does not define class method .call' do
      it 'raises a RequiredClassMethodMissingError' do
        expect do
          described_class.call(
            command: :InvalidCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V2 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommand::Dispatcher::RequiredClassMethodMissingError, 'Class "Api::AppName::V2::InvalidCommand" does not respond_to? class method "call".')
      end
    end
  end
end

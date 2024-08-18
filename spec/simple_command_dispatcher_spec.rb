# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SimpleCommandDispatcher, type: :module do
  it 'has a version number' do
    expect(SimpleCommandDispatcher::VERSION).to_not be_nil
  end

  describe '.call' do
    context 'when keyword argument :command is blank?' do
      it 'raises an ArgumentError when an empty string' do
        expect do
          described_class.call(
            command: '',
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, 'command is empty?')
      end

      it 'raises an ArgumentError when nil' do
        expect do
          described_class.call(
            command: nil,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(ArgumentError, /command is not a String or Symbol/)
      end
    end

    context 'when keyword argument :command is not a valid command' do
      it 'raises a Errors::InvalidClassConstantError error' do
        expect do
          described_class.call(
            command: :BadCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V1 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommandDispatcher::Errors::InvalidClassConstantError, /"Api::AppName::V1::BadCommand" is not a valid class constant/)
      end
    end

    context 'when keyword argument :command_namespace is blank?' do
      it 'does not raise an error when an empty string' do
        expect do
          described_class.call(
            command: :NoNamespacesCommand,
            command_namespace: '',
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to_not raise_error
      end

      it 'does not raise an error when nil' do
        expect do
          described_class.call(
            command: :NoNamespacesCommand,
            command_namespace: nil,
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to_not raise_error
      end
    end

    context 'when keyword argument :command_namespace is not a String, Hash or Array' do
      it 'raises an Argument error' do
        expect do
          described_class.call(
            command: :GoodCommandB,
            command_namespace: :bad_namespace
          )
        end.to raise_error(ArgumentError, 'Argument command_namespace is not a String, Hash or Array.')
      end
    end

    context 'when keyword argument :command_namespace is not a valid command' do
      it 'raises a Errors::InvalidClassConstantError error' do
        expect do
          described_class.call(
            command: :GoodCommandB,
            command_namespace: %i[Api BadAppName V1],
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommandDispatcher::Errors::InvalidClassConstantError, /"Api::BadAppName::V1::GoodCommandB" is not a valid class constant/)
      end
    end

    context 'when all the keyword arguments are valid' do
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
        command: :NoNamespacesCommand,
        request_params: { param1: :param1, param2: :param2, param3: :param3 }
      )
      expect(command.success?).to be(true)
    end
  end

  it 'works if command modules are lower-case' do
    command = described_class.call(
      command: :GoodCommandB,
      command_namespace: [:api, 'appName', :v1],
      request_params: { param1: :param1, param2: :param2, param3: :param3 }
    )
    expect(command.success?).to be(true)
  end

  it 'works if command is a route' do
    command = described_class.call(
      command: '/api/app_name/v1/good_command_b',
      request_params: { param1: :param1, param2: :param2, param3: :param3 }
    )
    expect(command.success?).to be(true)
  end

  it 'works if command namespace is a route' do
    command = described_class.call(
      command: 'good_command_b',
      command_namespace: '/api/app_name/v1',
      request_params: { param1: :param1, param2: :param2, param3: :param3 }
    )
    expect(command.success?).to be(true)
  end

  it 'works if command_namespace is a route that has a format associated with it' do
    route = '/api/app_name/v1/something_else.json'.split('/').slice(0, 4).join('/')
    command = described_class.call(
      command: :GoodCommandB,
      command_namespace: route,
      request_params: { param1: :param1, param2: :param2, param3: :param3 }
    )
    expect(command.success?).to be(true)
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
      it "raises a Errors::InvalidClassConstantError if doesn't respond_to? class method .call" do
        expect do
          described_class.call(
            command: :InvalidCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V2 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError, 'Class "Api::AppName::V2::InvalidCommand" does not respond_to? class method "call".')
      end
    end

    context 'when the command does not define class method .call' do
      it 'raises a Errors::RequiredClassMethodMissingError' do
        expect do
          described_class.call(
            command: :InvalidCommand,
            command_namespace: { api: :Api, app_name: :AppName, api_version: :V2 },
            request_params: { param1: :param1, param2: :param2, param3: :param3 }
          )
        end.to raise_error(SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError, 'Class "Api::AppName::V2::InvalidCommand" does not respond_to? class method "call".')
      end
    end

    context 'when the command has no request_params' do
      it 'does not raise an error' do
        expect do
          described_class.call(
            command: :NoNamespacesNoParamsCommand
          )
        end.to_not raise_error
      end
    end

    context 'when the command has one request_params' do
      it 'does not raise an error' do
        expect do
          described_class.call(
            command: :NoNamespacesOneParamCommand,
            request_params: :param
          )
        end.to_not raise_error
      end
    end
  end
end

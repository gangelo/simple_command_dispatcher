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
        expect do SimpleCommand::Dispatcher.call('', { api: :Api, app_name: :AppName, api_version: :V1 }, {},
          { param1: :param1, param2: :param2, param3: :param3 })
        end.to raise_error(ArgumentError, 'Class is empty?')
      end
    end

    context 'when argument :command is nil' do
      it 'raises an error' do
        expect do SimpleCommand::Dispatcher.call(nil, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
          { param1: :param1, param2: :param2, param3: :param3 })
        end.to raise_error(ArgumentError, /Class is not a String or Symbol/)
      end
    end

    context 'when argument :command is not a valid command' do
      it 'raises an error' do
        expect do SimpleCommand::Dispatcher.call(:BadCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
          { param1: :param1, param2: :param2, param3: :param3 })
        end.to raise_error(NameError, /"Api::AppName::V1::BadCommand" is not a valid class constant/)
      end
    end

    context 'when argument :command_namespace is not a valid command' do
      it 'raises an error' do
        expect do SimpleCommand::Dispatcher.call(:TestCommand, [:Api, :BadAppName, :V1], {},
          { param1: :param1, param2: :param2, param3: :param3 })
        end.to raise_error(NameError, /"Api::BadAppName::V1::TestCommand" is not a valid class constant/)
      end
    end

    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect do SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
          { param1: :param1, param2: :param2, param3: :param3 })
        end.not_to raise_error
      end
    end
  end

  context 'command Parameter' do
    it 'should return success? if command_namespace is a string' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, 'Api::AppName::V1', {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command] contains api qualifiers and [command_qualifiers] are nil' do
      command = SimpleCommand::Dispatcher.call('Api::AppName::V1::TestCommand', {}, {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command] contains api qualifiers and [command_qualifiers] are nil' do
      command = SimpleCommand::Dispatcher.call('Api::AppName::V2::TestCommand', {}, {}, :param1, :param2, :param3)
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command_qualifiers] are passed as an array of Symbols' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, %i[Api AppName V1], {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if [command_qualifiers] are passed as an array of Strings' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, %w[Api AppName V1], {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should work with commands that are not embedded in any modules' do
      command = SimpleCommand::Dispatcher.call(:NoQualifiersCommand, nil, {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end
  end

  context 'options Parameter' do
    it 'should work if command modules are lower-case and module_titleize option is set to true' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, [:api, 'appName', :v1], { module_titleize: true },
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should work if command module is a route and camelize option is set to true' do
      command = SimpleCommand::Dispatcher.call('test_command', '/api/app_name/v1', { camelize: true },
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should work if command is a route and camelize option is set to true' do
      command = SimpleCommand::Dispatcher.call('/api/app_name/v1/test_command', '', { camelize: true },
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should work if command is a route that has a format associated with it and camelize option is set to true' do
      route = '/api/app_name/v1/something_else.json'.split('/').slice(0, 4).join('/')
      command = SimpleCommand::Dispatcher.call(:TestCommand, route, { camelize: true },
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    # it "should work if command is lower-case and titleize_command option is set to true" do
    #   command = SimpleCommand::Dispatcher.call(:testCommand, [:Api, :AppName, :v2], {titleize_command: true}, :param1, :param2, :param3 )
    #   expect(command.success?).to eq(true)
    # end
  end

  context 'Custom Commands' do
    before(:each) do
      SimpleCommand::Dispatcher.configure do |config|
        config.allow_custom_commands = true
      end
    end

    it 'should work with custom commands' do
      result = SimpleCommand::Dispatcher.call(:CustomCommand,
                                              { api: :Api, app_name: :AppName, api_version: :V1 }, {}, { param1: :param1 })
      expect(result).to eq(true)
    end

    it 'should work with SimpleCommand commands when allowing custom commands' do
      command = SimpleCommand::Dispatcher.call(:TestCommand,
                                               { api: :Api, app_name: :AppName, api_version: :V1 }, {}, { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it "should raise NameError if doesn't respond_to? ::call" do
      expect do
        SimpleCommand::Dispatcher.call(:InvalidCustomCommand,
                                       { api: :Api, app_name: :AppName, api_version: :V2 }, {}, { param1: :param1, param2: :param2, param3: :param3 })
      end
        .to raise_error(NameError,
                        'Class "Api::AppName::V2::InvalidCustomCommand" does not respond_to? method ::call.')
    end
  end
end

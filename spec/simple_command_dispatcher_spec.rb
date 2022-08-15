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

  it 'should return success? if successful' do
    command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                             { param1: :param1, param2: :param2, param3: :param3 })
    expect(command.success?).to eq(true)
  end

  it 'should return failure? if unsuccessful' do
    command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                             { param1: :bad_param_param1, param2: :param2, param3: :param3 })
    expect(command.failure?).to eq(true)
  end

  context 'command Parameter' do
    it 'should throw an exception if the command is empty' do
      expect do
        SimpleCommand::Dispatcher.call('', { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                       { param1: :bad_param_param1, param2: :param2, param3: :param3 })
      end
        .to raise_error(ArgumentError, 'Class is empty?')
    end

    it 'should throw an exception if parameter [command] is not a Symbol or a String' do
      expect do
        SimpleCommand::Dispatcher.call([kill: :me], { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                       { param1: :bad_param_param1, param2: :param2, param3: :param3 })
      end
        .to raise_error(ArgumentError,
                        'Class is not a String or Symbol. Class must equal the class name of the SimpleCommand or Command to call in the form of a String or Symbol.')
    end

    it 'should throw an exception if parameter [command] is not a valid constant' do
      expect do
        SimpleCommand::Dispatcher.call(:NameErrorCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                       { param1: :param1, param2: :param2, param3: :param3 })
      end
        .to raise_error(NameError, '"Api::AppName::V1::NameErrorCommand" is not a valid class constant.')
    end

    it 'should throw an exception if parameter [command] does not prepend module SimpleCommand' do
      expect do
        SimpleCommand::Dispatcher.call(:InvalidCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                       { param1: :bad_param_param1, param2: :param2, param3: :param3 })
      end
        .to raise_error(ArgumentError,
                        'Class "Api::AppName::V1::InvalidCommand" must prepend module SimpleCommand if Configuration#allow_custom_commands is true.')
    end

    it 'should return success? if parameter [command] is a String' do
      command = SimpleCommand::Dispatcher.call('TestCommand', { api: :Api, app_name: :AppName, api_version: :V1 },
                                               {}, { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if parameter [command] is a Symbol' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, { api: :Api, app_name: :AppName, api_version: :V1 }, {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if command_modules are combined as strings' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, { api_qualifier: 'Api::AppName', version: :V1 }, {},
                                               { param1: :param1, param2: :param2, param3: :param3 })
      expect(command.success?).to eq(true)
    end

    it 'should return success? if command_modules is a string' do
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

    it 'should return success? if [command_qualifiers] are passed as an array' do
      command = SimpleCommand::Dispatcher.call(:TestCommand, %i[Api AppName V1], {},
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

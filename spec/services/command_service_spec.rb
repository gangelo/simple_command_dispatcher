# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Services::CommandService do
  subject(:command_service) do
    SimpleCommandDispatcher::Services::CommandService.new(command:, command_namespace:)
  end

  # describe 'when passing bad class modules' do
  #   it 'throws an exception' do
  #     expect { command_service.to_modules_string(1) }
  #       .to raise_error(ArgumentError, 'Argument command_modules is not a String, Hash or Array.')
  #   end
  # end

  # describe 'Tests for #camelize' do
  #   it 'returns a camelized string from a route' do
  #     result = command_service.camelize('/api/auth/app_name/v1/authenticate')
  #     expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
  #   end
  # end

  describe '#to_class' do
    context 'when using the default options' do
      let(:command) { 'Authenticate' }
      let(:command_namespace) { 'Api::Auth::AppName::V1' }

      it 'creates a constantized class string with the detault options' do
        result = command_service.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end

    context 'when titleize_module option is set to true' do
      let(:command) { 'Authenticate' }
      let(:command_namespace) { 'api::auth::appName::v1' }

      it 'creates a constantized class string with the titleize_module option set to true' do
        result = command_service.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end

    context 'when titleize_class option is set to false' do
      let(:command) { 'Authenticate' }
      let(:command_namespace) { 'Api::Auth::AppName::V1' }

      it 'creates a constantized class string with the titleize_class option set to false' do
        result = command_service.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end
  end

  # describe 'when using the default options' do
  #   describe 'when passing modules as a string' do
  #     it 'transforms the string into a module string' do
  #       result = command_service.to_modules_string('Api::Auth::AppName::V1')
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end

  #   describe 'when passing modules as an Array of symbols' do
  #     it 'transforms an array of symbols to a module string' do
  #       result = command_service.to_modules_string(%i[Api Auth AppName V1])
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of symbols to a module string' do
  #       result = command_service.to_modules_string({ api: :Api, auth: :Auth, app_name: :AppName, api_version: :V1 })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end

  #   describe 'when passing modules as strings' do
  #     it 'transforms an array of strings to a module string' do
  #       result = command_service.to_modules_string(%w[Api Auth AppName V1])
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of strings to a module string' do
  #       result = command_service.to_modules_string({ api: 'Api', auth: 'Auth', app_name: 'AppName', api_version: 'V1' })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end
  # end

  # describe 'when using the :titleize_modules option' do
  #   describe 'when passing modules as symbols' do
  #     it 'transforms an array of symbols to a module string' do
  #       result = command_service.to_modules_string(%i[api auth app_name v1], { titleize_module: true })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of symbols to a module string' do
  #       result = command_service.to_modules_string({ api: 'api', auth: 'auth', app_name: ' app_name', api_version: 'v1' },
  #         { titleize_module: true })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end
  # end
end

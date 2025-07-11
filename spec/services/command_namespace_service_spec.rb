# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Services::CommandNamespaceService do
  subject(:service) { described_class.new(command_namespace: command_namespace) }

  describe '#to_class_modules_string' do
    context 'when command_namespace is blank' do
      let(:command_namespace) { nil }

      it 'returns empty string' do
        expect(service.to_class_modules_string).to eq('')
      end
    end

    context 'when command_namespace is empty string' do
      let(:command_namespace) { '' }

      it 'returns empty string' do
        expect(service.to_class_modules_string).to eq('')
      end
    end

    context 'when command_namespace is a string' do
      let(:command_namespace) { 'Api' }

      it 'returns the string with double colon suffix' do
        expect(service.to_class_modules_string).to eq('Api::')
      end
    end

    context 'when command_namespace is a complex string' do
      let(:command_namespace) { 'Api::Auth::V1' }

      it 'returns the string with double colon suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is a lowercase string' do
      let(:command_namespace) { 'api::auth::v1' }

      it 'camelizes and returns the string with double colon suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is a string with underscores' do
      let(:command_namespace) { 'app_name::auth_service' }

      it 'camelizes and returns the string with double colon suffix' do
        expect(service.to_class_modules_string).to eq('AppName::AuthService::')
      end
    end

    context 'when command_namespace is a string with spaces' do
      let(:command_namespace) { 'Api :: Auth :: V1' }

      it 'trims spaces and returns the string with double colon suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is an array of strings' do
      let(:command_namespace) { ['Api', 'Auth', 'V1'] }

      it 'joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is an array of symbols' do
      let(:command_namespace) { [:Api, :Auth, :V1] }

      it 'joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is an array of mixed case strings' do
      let(:command_namespace) { ['api', 'auth', 'v1'] }

      it 'camelizes and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is an array with underscores' do
      let(:command_namespace) { ['app_name', 'auth_service'] }

      it 'camelizes and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('AppName::AuthService::')
      end
    end

    context 'when command_namespace is an empty array' do
      let(:command_namespace) { [] }

      it 'returns empty string' do
        expect(service.to_class_modules_string).to eq('')
      end
    end

    context 'when command_namespace is a hash with symbol keys' do
      let(:command_namespace) { { api: :Api, auth: :Auth, version: :V1 } }

      it 'uses values and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is a hash with string keys' do
      let(:command_namespace) { { 'api' => 'Api', 'auth' => 'Auth', 'version' => 'V1' } }

      it 'uses values and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is a hash with lowercase values' do
      let(:command_namespace) { { api: :api, auth: :auth, version: :v1 } }

      it 'camelizes values and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
      end
    end

    context 'when command_namespace is a hash with underscore values' do
      let(:command_namespace) { { app: :app_name, service: :auth_service } }

      it 'camelizes values and joins with double colons and adds suffix' do
        expect(service.to_class_modules_string).to eq('AppName::AuthService::')
      end
    end

    context 'when command_namespace is an empty hash' do
      let(:command_namespace) { {} }

      it 'returns empty string' do
        expect(service.to_class_modules_string).to eq('')
      end
    end

    context 'edge cases' do
      context 'when command_namespace is a single character string' do
        let(:command_namespace) { 'A' }

        it 'returns the character with double colon suffix' do
          expect(service.to_class_modules_string).to eq('A::')
        end
      end

      context 'when command_namespace is a string with only spaces' do
        let(:command_namespace) { '   ' }

        it 'returns empty string after trimming' do
          expect(service.to_class_modules_string).to eq('')
        end
      end

      context 'when command_namespace array has empty strings' do
        let(:command_namespace) { ['Api', '', 'V1'] }

        it 'includes empty string in the result' do
          expect(service.to_class_modules_string).to eq('Api::V1::')
        end
      end

      context 'when command_namespace array has nil values' do
        let(:command_namespace) { ['Api', nil, 'V1'] }

        it 'includes nil in the result' do
          expect(service.to_class_modules_string).to eq('Api::V1::')
        end
      end

      context 'when command_namespace hash has nil values' do
        let(:command_namespace) { { api: :Api, auth: nil, version: :V1 } }

        it 'includes nil in the result' do
          expect(service.to_class_modules_string).to eq('Api::V1::')
        end
      end

      context 'when command_namespace is a deeply nested namespace' do
        let(:command_namespace) { ['Api', 'Services', 'Auth', 'Providers', 'OAuth', 'Google', 'V2'] }

        it 'handles deep nesting correctly' do
          expect(service.to_class_modules_string).to eq('Api::Services::Auth::Providers::OAuth::Google::V2::')
        end
      end

      context 'when command_namespace contains route-like strings' do
        let(:command_namespace) { '/api/auth/v1' }

        it 'converts route to module format' do
          expect(service.to_class_modules_string).to eq('Api::Auth::V1::')
        end
      end
    end
  end

  describe '#initialize' do
    it 'sets command_namespace as an instance variable' do
      service = described_class.new(command_namespace: 'TestNamespace')
      expect(service.send(:command_namespace)).to eq('TestNamespace')
    end
  end
end

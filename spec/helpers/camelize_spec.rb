# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Helpers::Camelize do
  let(:test_class) do
    Class.new do
      include SimpleCommandDispatcher::Helpers::Camelize
    end
  end

  subject(:helper) { test_class.new }

  describe '#camelize' do
    context 'with route-like strings' do
      it 'converts basic route to module format' do
        expect(helper.camelize('/api/app/auth/v1')).to eq('Api::App::Auth::V1')
      end

      it 'converts route with underscores to camelized modules' do
        expect(helper.camelize('/api/app_name/auth/v1')).to eq('Api::AppName::Auth::V1')
      end

      it 'converts route with mixed case to proper modules' do
        expect(helper.camelize('/API/appName/AUTH/v1')).to eq('Api::AppName::Auth::V1')
      end

      it 'handles route without leading slash' do
        expect(helper.camelize('api/app/auth/v1')).to eq('Api::App::Auth::V1')
      end

      it 'handles route with trailing slash' do
        expect(helper.camelize('/api/app/auth/v1/')).to eq('Api::App::Auth::V1')
      end
    end

    context 'with module-like strings' do
      it 'converts double-colon separated modules' do
        expect(helper.camelize('api::app::auth::v1')).to eq('Api::App::Auth::V1')
      end

      it 'handles already properly formatted modules' do
        expect(helper.camelize('Api::App::Auth::V1')).to eq('Api::App::Auth::V1')
      end

      it 'handles mixed separators' do
        expect(helper.camelize('api/app::auth/v1')).to eq('Api::App::Auth::V1')
      end
    end

    context 'with single words' do
      it 'camelizes lowercase word' do
        expect(helper.camelize('api')).to eq('Api')
      end

      it 'camelizes uppercase word' do
        expect(helper.camelize('API')).to eq('Api')
      end

      it 'camelizes mixed case word' do
        # NOTE: This results are not ideal; however, if the user uses
        # mixed case resttul APIs, it becomes impossible to interpret
        # constant-wise what that might look like.
        expect(helper.camelize('aPi')).to eq('APi')
      end

      it 'camelizes underscore word' do
        expect(helper.camelize('app_name')).to eq('AppName')
      end

      it 'handles already camelized word' do
        expect(helper.camelize('AppName')).to eq('AppName')
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty string' do
        expect(helper.camelize('')).to be_nil
      end

      it 'handles single character' do
        expect(helper.camelize('a')).to eq('A')
      end

      it 'handles single slash' do
        expect(helper.camelize('/')).to eq('')
      end

      it 'handles multiple slashes' do
        expect(helper.camelize('///')).to eq('')
      end

      it 'handles string with only underscores' do
        expect(helper.camelize('___')).to eq('')
      end

      it 'handles string with spaces' do
        # NOTE: This results are not ideal; however, if the user uses
        # embedded spaces in their resttul APIs, it becomes impossible
        # to interpret constant-wise what that might look like.
        expect(helper.camelize('api app auth')).to eq('Apiappauth')
      end

      it 'handles string with mixed separators and spaces' do
        expect(helper.camelize(' /api / app_name :: auth / v1 ')).to eq('Api::AppName::Auth::V1')
      end

      it 'removes leading colons' do
        expect(helper.camelize('::api::app')).to eq('Api::App')
      end

      it 'handles numeric components' do
        expect(helper.camelize('/api/v1/auth')).to eq('Api::V1::Auth')
      end

      it 'handles long nested paths' do
        long_path = '/api/services/auth/providers/oauth/google/v2/endpoints'
        expected = 'Api::Services::Auth::Providers::Oauth::Google::V2::Endpoints'
        expect(helper.camelize(long_path)).to eq(expected)
      end
    end

    context 'with special characters' do
      it 'handles hyphens as separators' do
        expect(helper.camelize('api-app-auth')).to eq('Api::App::Auth')
      end

      it 'handles dots as separators' do
        expect(helper.camelize('api.app.auth')).to eq('Api::App::Auth')
      end

      it 'handles multiple separator types' do
        expect(helper.camelize('api-app_name.auth/v1')).to eq('Api::AppName::Auth::V1')
      end
    end

    context 'with invalid input' do
      it 'raises ArgumentError for non-string input' do
        expect { helper.camelize(123) }.to raise_error(ArgumentError, 'Token is not a String')
      end

      it 'raises ArgumentError for nil input' do
        expect { helper.camelize(nil) }.to raise_error(ArgumentError, 'Token is not a String')
      end

      it 'raises ArgumentError for symbol input' do
        expect { helper.camelize(:api) }.to raise_error(ArgumentError, 'Token is not a String')
      end

      it 'raises ArgumentError for array input' do
        expect { helper.camelize(['api']) }.to raise_error(ArgumentError, 'Token is not a String')
      end
    end

    context 'with unicode characters' do
      it 'handles unicode characters' do
        expect(helper.camelize('api/café/naïve')).to eq('Api::Café::Naïve')
      end

      it 'handles unicode in underscores' do
        expect(helper.camelize('api_café_naïve')).to eq('ApiCaféNaïve')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommand::Dispatcher::KlassTransform do
  subject(:klass_transform) do
    SimpleCommand::Dispatcher::KlassTransform.new(klass, klass_modules, options)
  end

  # describe 'when passing bad class modules' do
  #   it 'throws an exception' do
  #     expect { klass_transform.to_modules_string(1) }
  #       .to raise_error(ArgumentError, 'Argument klass_modules is not a String, Hash or Array.')
  #   end
  # end

  # describe 'Tests for #camelize' do
  #   it 'returns a camelized string from a route' do
  #     result = klass_transform.camelize('/api/auth/app_name/v1/authenticate')
  #     expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
  #   end
  # end

  describe '#to_class' do
    context 'when using the default options' do
      let(:klass) { 'Authenticate' }
      let(:klass_modules) { 'Api::Auth::AppName::V1' }
      let(:options) { {} }

      it 'creates a constantized class string with the detault options' do
        result = klass_transform.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end

    context 'when module_titleize option is set to true' do
      let(:klass) { 'Authenticate' }
      let(:klass_modules) { 'api::auth::appName::v1' }
      let(:options) { { module_titleize: true } }

      it 'creates a constantized class string with the module_titleize option set to true' do
        result = klass_transform.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end

    context 'when class_titleize option is set to false' do
      let(:klass) { 'Authenticate' }
      let(:klass_modules) { 'Api::Auth::AppName::V1' }
      let(:options) { { class_titleize: false } }

      it 'creates a constantized class string with the class_titleize option set to false' do
        result = klass_transform.to_class
        expect(result).to eq(Api::Auth::AppName::V1::Authenticate)
      end
    end
  end

  # describe 'when using the default options' do
  #   describe 'when passing modules as a string' do
  #     it 'transforms the string into a module string' do
  #       result = klass_transform.to_modules_string('Api::Auth::AppName::V1')
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end

  #   describe 'when passing modules as an Array of symbols' do
  #     it 'transforms an array of symbols to a module string' do
  #       result = klass_transform.to_modules_string(%i[Api Auth AppName V1])
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of symbols to a module string' do
  #       result = klass_transform.to_modules_string({ api: :Api, auth: :Auth, app_name: :AppName, api_version: :V1 })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end

  #   describe 'when passing modules as strings' do
  #     it 'transforms an array of strings to a module string' do
  #       result = klass_transform.to_modules_string(%w[Api Auth AppName V1])
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of strings to a module string' do
  #       result = klass_transform.to_modules_string({ api: 'Api', auth: 'Auth', app_name: 'AppName', api_version: 'V1' })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end
  # end

  # describe 'when using the :titleize_modules option' do
  #   describe 'when passing modules as symbols' do
  #     it 'transforms an array of symbols to a module string' do
  #       result = klass_transform.to_modules_string(%i[api auth app_name v1], { module_titleize: true })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end

  #     it 'transforms a hash of symbols to a module string' do
  #       result = klass_transform.to_modules_string({ api: 'api', auth: 'auth', app_name: ' app_name', api_version: 'v1' },
  #         { module_titleize: true })
  #       expect(result).to eq('Api::Auth::AppName::V1::')
  #     end
  #   end
  # end
end

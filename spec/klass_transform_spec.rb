# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommand::Dispatcher::KlassTransform do
  subject(:klass_transform) { KlassTransformTester.new }

  before do
    class KlassTransformTester
      include SimpleCommand::Dispatcher::KlassTransform
    end
  end

  describe 'when passing bad class modules' do
    it 'should throw an exception' do
      expect { klass_transform.to_modules_string(1) }
        .to raise_error(ArgumentError, 'Argument klass_modules is not a String, Hash or Array.')
    end
  end

  # describe "Tests for to_constantized_class" do
  #    it "should create a constantized class with the detault options" do
  #       result = klass_transform.to_constantized_class(:GoodCommandB, { api: :Api, app_name: :AppName, api_version: :V1 })
  #       expect(result).to eq(Api::AppName::V1::GoodCommandB)
  #    end
  # end

  describe 'Tests for #camelize' do
    it 'should return a camelized string from a route' do
      result = klass_transform.camelize('/api/auth/app_name/v1/authenticate')
      expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
    end
  end

  describe 'Tests for #to_constantized_class_string' do
    it 'should create a constantized class string with the detault options' do
      result = klass_transform.to_constantized_class_string(:Authenticate,
                                                { api: :Api, auth: :Auth, app_name: :AppName, api_version: :V1 })
      expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
    end

    it 'should create a constantized class string with the module_titleize option set to true' do
      result = klass_transform.to_constantized_class_string(:Authenticate,
                                                { api: :api, auth: :auth, app_name: :appName, api_version: :v1 }, { module_titleize: true })
      expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
    end

    it 'should create a constantized class string with the class_titleize option set to true' do
      result = klass_transform.to_constantized_class_string(:Authenticate,
                                                { api: :Api, auth: :Auth, app_name: :AppName, api_version: :V1 }, { class_titleize: true })
      expect(result).to eq('Api::Auth::AppName::V1::Authenticate')
    end
  end

  describe 'when using the default options' do
    describe 'when passing modules as a string' do
      it 'should transform the string into a module string' do
        result = klass_transform.to_modules_string('Api::Auth::AppName::V1')
        expect(result).to eq('Api::Auth::AppName::V1::')
      end
    end

    describe 'when passing modules as an Array of symbols' do
      it 'should transform an array of symbols to a module string' do
        result = klass_transform.to_modules_string(%i[Api Auth AppName V1])
        expect(result).to eq('Api::Auth::AppName::V1::')
      end

      it 'should transform a hash of symbols to a module string' do
        result = klass_transform.to_modules_string({ api: :Api, auth: :Auth, app_name: :AppName, api_version: :V1 })
        expect(result).to eq('Api::Auth::AppName::V1::')
      end
    end

    describe 'when passing modules as strings' do
      it 'should transform an array of strings to a module string' do
        result = klass_transform.to_modules_string(%w[Api Auth AppName V1])
        expect(result).to eq('Api::Auth::AppName::V1::')
      end

      it 'should transform a hash of strings to a module string' do
        result = klass_transform.to_modules_string({ api: 'Api', auth: 'Auth', app_name: 'AppName', api_version: 'V1' })
        expect(result).to eq('Api::Auth::AppName::V1::')
      end
    end
  end

  describe 'when using the :titleize_modules option' do
    describe 'when passing modules as symbols' do
      it 'should transform an array of symbols to a module string' do
        result = klass_transform.to_modules_string(%i[api auth app_name v1], { module_titleize: true })
        expect(result).to eq('Api::Auth::AppName::V1::')
      end

      it 'should transform a hash of symbols to a module string' do
        result = klass_transform.to_modules_string({ api: 'api', auth: 'auth', app_name: ' app_name', api_version: 'v1' },
                                       { module_titleize: true })
        expect(result).to eq('Api::Auth::AppName::V1::')
      end
    end
  end
end

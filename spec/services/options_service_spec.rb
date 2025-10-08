# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Services::OptionsService do
  subject(:options_service) { described_class.new(options:) }

  describe '#initialize' do
    context 'when no options are provided' do
      let(:options) { {} }

      it 'uses default options' do
        expect(options_service.debug?).to be false
      end
    end

    context 'when options are provided' do
      let(:options) { { debug: true } }

      it 'merges provided options with defaults' do
        expect(options_service.debug?).to be true
      end
    end

    context 'when invalid options are provided' do
      let(:options) { { invalid_option: 'value' } }

      it 'ignores invalid options' do
        expect(options_service.debug?).to be false
      end
    end
  end

  describe '#debug?' do
    context 'when debug is true' do
      let(:options) { { debug: true } }

      it 'returns true' do
        expect(options_service.debug?).to be true
      end
    end

    context 'when debug is false' do
      let(:options) { { debug: false } }

      it 'returns false' do
        expect(options_service.debug?).to be false
      end
    end

    context 'when debug is not provided' do
      let(:options) { {} }

      it 'returns false (default)' do
        expect(options_service.debug?).to be false
      end
    end
  end
end

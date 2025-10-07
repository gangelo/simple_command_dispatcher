# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Services::OptionsService do
  subject(:options_service) { described_class.new(options:) }

  describe '#initialize' do
    context 'when no options are provided' do
      let(:options) { {} }

      it 'uses default options' do
        expect(options_service.pretend?).to be false
      end
    end

    context 'when options are provided' do
      let(:options) { { pretend: true } }

      it 'merges provided options with defaults' do
        expect(options_service.pretend?).to be true
      end
    end

    context 'when invalid options are provided' do
      let(:options) { { invalid_option: 'value' } }

      it 'ignores invalid options' do
        expect(options_service.pretend?).to be false
      end
    end
  end

  describe '#pretend?' do
    context 'when pretend is true' do
      let(:options) { { pretend: true } }

      it 'returns true' do
        expect(options_service.pretend?).to be true
      end
    end

    context 'when pretend is false' do
      let(:options) { { pretend: false } }

      it 'returns false' do
        expect(options_service.pretend?).to be false
      end
    end

    context 'when pretend is not provided' do
      let(:options) { {} }

      it 'returns false (default)' do
        expect(options_service.pretend?).to be false
      end
    end
  end
end

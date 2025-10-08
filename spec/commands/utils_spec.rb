# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Commands::CommandCallable::Utils do
  describe '.array_wrap' do
    it 'returns empty array for nil' do
      expect(described_class.array_wrap(nil)).to eq([])
    end

    it 'wraps a single object in an array' do
      expect(described_class.array_wrap('string')).to eq(['string'])
      expect(described_class.array_wrap(42)).to eq([42])
      expect(described_class.array_wrap(:symbol)).to eq([:symbol])
    end

    it 'returns the array if object responds to to_ary' do
      array = [1, 2, 3]
      expect(described_class.array_wrap(array)).to eq([1, 2, 3])
    end

    it 'calls to_ary if object responds to it' do
      object = double('CustomObject')
      allow(object).to receive(:respond_to?).with(:to_ary).and_return(true)
      allow(object).to receive(:to_ary).and_return([1, 2, 3])

      expect(described_class.array_wrap(object)).to eq([1, 2, 3])
    end

    it 'wraps object if to_ary returns nil' do
      object = double('CustomObject')
      allow(object).to receive(:respond_to?).with(:to_ary).and_return(true)
      allow(object).to receive(:to_ary).and_return(nil)

      expect(described_class.array_wrap(object)).to eq([object])
    end

    it 'handles hash objects' do
      hash = { key: 'value' }
      expect(described_class.array_wrap(hash)).to eq([hash])
    end

    it 'handles empty strings' do
      expect(described_class.array_wrap('')).to eq([''])
    end

    it 'handles false and true' do
      expect(described_class.array_wrap(false)).to eq([false])
      expect(described_class.array_wrap(true)).to eq([true])
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommand::Dispatcher do
  describe '.configure' do
    it 'does nothing at the moment' do
      expect do
        described_class.configure { |config| }
      end.to_not raise_error
    end
  end

  describe '#reset' do
    it 'allows #reset to be called' do
      expect do
        described_class.configuration.reset
      end.to_not raise_error
    end
  end
end

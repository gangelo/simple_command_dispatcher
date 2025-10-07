# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher do
  describe '.configure' do
    it 'does nothing at the moment' do
      expect do
        described_class.configure { |config| }
      end.to_not raise_error
    end

    it 'allows configuration of logger' do
      custom_logger = double('CustomLogger')
      described_class.configure do |config|
        config.logger = custom_logger
      end
      expect(described_class.configuration.logger).to eq(custom_logger)
    end

    it 'returns the configuration object' do
      result = described_class.configure
      expect(result).to be_a(SimpleCommandDispatcher::Configuration)
    end
  end

  describe '#reset' do
    it 'allows #reset to be called' do
      expect do
        described_class.configuration.reset
      end.to_not raise_error
    end

    it 'resets logger to default' do
      custom_logger = double('CustomLogger')
      described_class.configure do |config|
        config.logger = custom_logger
      end
      described_class.configuration.reset
      expect(described_class.configuration.logger).to be_a(::Logger)
    end
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(described_class.configuration).to be_a(SimpleCommandDispatcher::Configuration)
    end

    it 'returns the same instance on multiple calls' do
      config1 = described_class.configuration
      config2 = described_class.configuration
      expect(config1).to eq(config2)
    end
  end
end

describe SimpleCommandDispatcher::Configuration do
  subject(:configuration) { described_class.new }

  describe '#initialize' do
    it 'sets default logger' do
      expect(configuration.logger).to be_a(::Logger)
    end
  end

  describe '#logger' do
    it 'can be set to a custom logger' do
      custom_logger = double('CustomLogger')
      configuration.logger = custom_logger
      expect(configuration.logger).to eq(custom_logger)
    end
  end

  describe '#reset' do
    it 'resets logger to default' do
      custom_logger = double('CustomLogger')
      configuration.logger = custom_logger
      configuration.reset
      expect(configuration.logger).to be_a(::Logger)
    end
  end
end

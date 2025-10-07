# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Logger do
  let(:test_class) do
    Class.new do
      extend SimpleCommandDispatcher::Logger
    end
  end

  describe '#log_debug' do
    context 'when logger is configured' do
      let(:logger) { double('Logger') }

      before do
        allow(SimpleCommandDispatcher.configuration).to receive(:logger).and_return(logger)
      end

      it 'calls debug on the configured logger' do
        expect(logger).to receive(:debug).with('test message')
        test_class.send(:log_debug, 'test message')
      end
    end

    context 'when logger does not respond to debug' do
      let(:logger) { double('Logger') }

      before do
        allow(SimpleCommandDispatcher.configuration).to receive(:logger).and_return(logger)
        allow(logger).to receive(:respond_to?).with(:debug).and_return(false)
      end

      it 'does not raise an error' do
        expect { test_class.send(:log_debug, 'test message') }.not_to raise_error
      end
    end
  end

  describe '#log_error' do
    context 'when logger is configured' do
      let(:logger) { double('Logger') }

      before do
        allow(SimpleCommandDispatcher.configuration).to receive(:logger).and_return(logger)
      end

      it 'calls error on the configured logger' do
        expect(logger).to receive(:error).with('error message')
        test_class.send(:log_error, 'error message')
      end
    end

    context 'when logger does not respond to error' do
      let(:logger) { double('Logger') }

      before do
        allow(SimpleCommandDispatcher.configuration).to receive(:logger).and_return(logger)
        allow(logger).to receive(:respond_to?).with(:error).and_return(false)
      end

      it 'does not raise an error' do
        expect { test_class.send(:log_error, 'error message') }.not_to raise_error
      end
    end
  end
end

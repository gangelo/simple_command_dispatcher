# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError do
  describe '#initialize' do
    it 'creates error with class constant' do
      test_class = Class.new
      error = described_class.new(test_class)

      expect(error).to be_a(StandardError)
      expect(error.message).to eq("Class \"#{test_class}\" does not respond_to? class method \"call\".")
    end

    it 'handles named class' do
      class TestCommand
      end

      error = described_class.new(TestCommand)

      expect(error.message).to eq('Class "TestCommand" does not respond_to? class method "call".')
    end

    it 'handles namespaced class' do
      module TestModule
        class TestCommand
        end
      end

      error = described_class.new(TestModule::TestCommand)

      expect(error.message).to eq('Class "TestModule::TestCommand" does not respond_to? class method "call".')
    end

    it 'handles deeply nested class' do
      module Api
        module V1
          module Commands
            class TestCommand
            end
          end
        end
      end

      error = described_class.new(Api::V1::Commands::TestCommand)

      expect(error.message).to eq('Class "Api::V1::Commands::TestCommand" does not respond_to? class method "call".')
    end
  end

  describe 'error formatting' do
    it 'formats class names correctly' do
      class SimpleCommand
      end

      error = described_class.new(SimpleCommand)

      expect(error.message).to include('"SimpleCommand"')
      expect(error.message).to include('does not respond_to?')
      expect(error.message).to include('class method "call"')
    end

    it 'formats anonymous classes correctly' do
      anonymous_class = Class.new
      error = described_class.new(anonymous_class)

      expect(error.message).to include(anonymous_class.to_s)
      expect(error.message).to match(/Class "#<Class:0x[0-9a-f]+>"/)
    end

    it 'handles module objects' do
      test_module = Module.new
      error = described_class.new(test_module)

      expect(error.message).to include(test_module.to_s)
    end

    it 'handles class with special characters in name' do
      class Command_With_Underscores
      end

      error = described_class.new(Command_With_Underscores)

      expect(error.message).to include('"Command_With_Underscores"')
    end
  end

  describe 'inheritance' do
    it 'inherits from StandardError' do
      error = described_class.new(Class.new)

      expect(error).to be_a(StandardError)
      expect(error.class.ancestors).to include(StandardError)
    end

    it 'can be rescued as StandardError' do
      expect {
        raise described_class.new(Class.new)
      }.to raise_error(StandardError)
    end

    it 'can be rescued by specific class' do
      expect {
        raise described_class.new(Class.new)
      }.to raise_error(described_class)
    end
  end

  describe 'real-world usage scenarios' do
    it 'handles classes without call method' do
      class CommandWithoutCall
        def self.execute
          'executed'
        end
      end

      error = described_class.new(CommandWithoutCall)

      expect(error.message).to include('CommandWithoutCall')
      expect(error.message).to include('does not respond_to?')
      expect(error.message).to include('class method "call"')
    end

    it 'handles classes with instance call method but no class call method' do
      class CommandWithInstanceCall
        def call
          'instance call'
        end
      end

      error = described_class.new(CommandWithInstanceCall)

      expect(error.message).to include('CommandWithInstanceCall')
      expect(error.message).to include('class method "call"')
    end

    it 'handles classes with private call method' do
      class CommandWithPrivateCall
        private_class_method def self.call
          'private call'
        end
      end

      error = described_class.new(CommandWithPrivateCall)

      expect(error.message).to include('CommandWithPrivateCall')
    end

    it 'handles classes that inherit from other classes' do
      class BaseCommand
      end

      class InheritedCommand < BaseCommand
      end

      error = described_class.new(InheritedCommand)

      expect(error.message).to include('InheritedCommand')
    end
  end

  describe 'edge cases' do
    it 'handles nil input gracefully' do
      error = described_class.new(nil)

      expect(error.message).to include('""')
      expect(error.message).to include('does not respond_to?')
    end

    it 'handles string input' do
      error = described_class.new('StringClass')

      expect(error.message).to eq("Class \"StringClass\" does not respond_to? class method \"call\".")
    end

    it 'handles symbol input' do
      error = described_class.new(:SymbolClass)
      expect(error.message).to eq("Class \"SymbolClass\" does not respond_to? class method \"call\".")
    end

    it 'handles numeric input' do
      error = described_class.new(123)

      expect(error.message).to include('123')
    end

    it 'handles array input' do
      error = described_class.new([1, 2, 3])

      expect(error.message).to include('[1, 2, 3]')
    end

    it 'handles hash input' do
      error = described_class.new({ key: 'value' })
      expect(error.message).to eq("Class \"{key: \"value\"}\" does not respond_to? class method \"call\".")
    end
  end

  describe 'method behavior' do
    it 'responds to standard Exception methods' do
      error = described_class.new(Class.new)

      expect(error).to respond_to(:message)
      expect(error).to respond_to(:backtrace)
      expect(error).to respond_to(:cause)
      expect(error).to respond_to(:to_s)
    end

    it 'to_s returns the message' do
      error = described_class.new(Class.new)

      expect(error.to_s).to eq(error.message)
    end

    it 'can be converted to string' do
      error = described_class.new(Class.new)

      expect(error.to_s).to be_a(String)
      expect(error.to_s).not_to be_empty
    end
  end

  describe 'integration with command validation' do
    it 'represents the expected error when command lacks call method' do
      class BadCommand
        def self.execute
          'executed'
        end
      end

      error = described_class.new(BadCommand)

      # This error should be raised when validating commands
      expect(error.message).to match(/does not respond_to\? class method "call"/)
    end

    it 'provides clear error message for debugging' do
      class DebugCommand
      end

      error = described_class.new(DebugCommand)

      expect(error.message).to include('DebugCommand')
      expect(error.message).to include('call')
      expect(error.message).to be_a(String)
      expect(error.message.length).to be > 20
    end
  end
end

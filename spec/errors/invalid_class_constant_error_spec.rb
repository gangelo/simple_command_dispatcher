# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Errors::InvalidClassConstantError do
  describe '#initialize' do
    it 'creates error with class string and error message' do
      error = described_class.new('Api::BadCommand', 'uninitialized constant Api::BadCommand')
      
      expect(error).to be_a(StandardError)
      expect(error.message).to eq('"Api::BadCommand" is not a valid class constant. Error message: "uninitialized constant Api::BadCommand".')
    end

    it 'handles empty class string' do
      error = described_class.new('', 'some error')
      
      expect(error.message).to eq('"" is not a valid class constant. Error message: "some error".')
    end

    it 'handles empty error message' do
      error = described_class.new('Api::BadCommand', '')
      
      expect(error.message).to eq('"Api::BadCommand" is not a valid class constant. Error message: "".')
    end

    it 'handles nil class string' do
      error = described_class.new(nil, 'some error')
      
      expect(error.message).to eq('"" is not a valid class constant. Error message: "some error".')
    end

    it 'handles nil error message' do
      error = described_class.new('Api::BadCommand', nil)
      
      expect(error.message).to eq('"Api::BadCommand" is not a valid class constant. Error message: "".')
    end
  end

  describe 'error formatting' do
    it 'formats simple class names correctly' do
      error = described_class.new('BadCommand', 'not found')
      
      expect(error.message).to include('"BadCommand"')
      expect(error.message).to include('not found')
    end

    it 'formats namespaced class names correctly' do
      error = described_class.new('Api::V1::BadCommand', 'uninitialized constant')
      
      expect(error.message).to include('"Api::V1::BadCommand"')
      expect(error.message).to include('uninitialized constant')
    end

    it 'formats deeply nested class names correctly' do
      deeply_nested = 'Api::Services::Auth::Providers::OAuth::Google::V2::BadCommand'
      error = described_class.new(deeply_nested, 'not found')
      
      expect(error.message).to include("\"#{deeply_nested}\"")
      expect(error.message).to include('not found')
    end

    it 'handles special characters in class names' do
      error = described_class.new('Api::Command_With_Underscores', 'not found')
      
      expect(error.message).to include('"Api::Command_With_Underscores"')
    end

    it 'handles special characters in error messages' do
      error_msg = 'Error: "uninitialized constant" with quotes'
      error = described_class.new('Api::BadCommand', error_msg)
      
      expect(error.message).to include(error_msg)
    end
  end

  describe 'inheritance' do
    it 'inherits from StandardError' do
      error = described_class.new('BadCommand', 'not found')
      
      expect(error).to be_a(StandardError)
      expect(error.class.ancestors).to include(StandardError)
    end

    it 'can be rescued as StandardError' do
      expect {
        raise described_class.new('BadCommand', 'not found')
      }.to raise_error(StandardError)
    end

    it 'can be rescued by specific class' do
      expect {
        raise described_class.new('BadCommand', 'not found')
      }.to raise_error(described_class)
    end
  end

  describe 'real-world usage scenarios' do
    it 'handles NameError-like messages' do
      error = described_class.new('Api::NonExistentCommand', 'uninitialized constant Api::NonExistentCommand')
      
      expect(error.message).to match(/uninitialized constant/)
      expect(error.message).to match(/Api::NonExistentCommand/)
    end

    it 'handles LoadError-like messages' do
      error = described_class.new('Api::BadCommand', 'cannot load such file -- api/bad_command')
      
      expect(error.message).to match(/cannot load such file/)
    end

    it 'handles SyntaxError-like messages' do
      error = described_class.new('Api::BadCommand', 'syntax error, unexpected end-of-input')
      
      expect(error.message).to match(/syntax error/)
    end

    it 'handles ArgumentError-like messages' do
      error = described_class.new('Api::BadCommand', 'wrong number of arguments')
      
      expect(error.message).to match(/wrong number of arguments/)
    end
  end

  describe 'edge cases' do
    it 'handles very long class names' do
      long_class_name = 'Api::' + ('VeryLongModuleName::' * 20) + 'Command'
      error = described_class.new(long_class_name, 'not found')
      
      expect(error.message).to include(long_class_name)
      expect(error.message.length).to be > 100
    end

    it 'handles very long error messages' do
      long_error = 'This is a very long error message that contains lots of details ' * 10
      error = described_class.new('Api::BadCommand', long_error)
      
      expect(error.message).to include(long_error)
    end

    it 'handles unicode characters in class names' do
      unicode_class = 'Api::Café::Naïve::Command'
      error = described_class.new(unicode_class, 'not found')
      
      expect(error.message).to include(unicode_class)
    end

    it 'handles unicode characters in error messages' do
      unicode_error = 'Erreur: constante non initialisée'
      error = described_class.new('Api::BadCommand', unicode_error)
      
      expect(error.message).to include(unicode_error)
    end

    it 'handles newlines in error messages' do
      multiline_error = "Error on line 1\nError on line 2\nError on line 3"
      error = described_class.new('Api::BadCommand', multiline_error)
      
      expect(error.message).to include(multiline_error)
    end
  end

  describe 'method behavior' do
    it 'responds to standard Exception methods' do
      error = described_class.new('BadCommand', 'not found')
      
      expect(error).to respond_to(:message)
      expect(error).to respond_to(:backtrace)
      expect(error).to respond_to(:cause)
      expect(error).to respond_to(:to_s)
    end

    it 'to_s returns the message' do
      error = described_class.new('BadCommand', 'not found')
      
      expect(error.to_s).to eq(error.message)
    end

    it 'can be converted to string' do
      error = described_class.new('BadCommand', 'not found')
      
      expect(error.to_s).to be_a(String)
      expect(error.to_s).not_to be_empty
    end
  end
end
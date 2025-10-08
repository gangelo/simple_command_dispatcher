# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Commands::CommandCallable::Errors do
  subject(:errors) { described_class.new }

  describe '#add' do
    it 'adds an error to the specified key' do
      errors.add(:name, 'is required')
      expect(errors[:name]).to eq(['is required'])
    end

    it 'adds multiple errors to the same key' do
      errors.add(:email, 'is required')
      errors.add(:email, 'is invalid')
      expect(errors[:email]).to eq(['is required', 'is invalid'])
    end

    it 'does not add duplicate errors' do
      errors.add(:name, 'is required')
      errors.add(:name, 'is required')
      expect(errors[:name]).to eq(['is required'])
    end

    it 'handles different keys independently' do
      errors.add(:name, 'is required')
      errors.add(:email, 'is invalid')
      expect(errors[:name]).to eq(['is required'])
      expect(errors[:email]).to eq(['is invalid'])
    end
  end

  describe '#add_multiple_errors' do
    it 'adds multiple errors from a hash with single values' do
      errors.add_multiple_errors(name: 'is required', email: 'is invalid')
      expect(errors[:name]).to eq(['is required'])
      expect(errors[:email]).to eq(['is invalid'])
    end

    it 'adds multiple errors from a hash with array values' do
      errors.add_multiple_errors(
        email: ['is required', 'is invalid'],
        password: ['is too short', 'is too weak']
      )
      expect(errors[:email]).to eq(['is required', 'is invalid'])
      expect(errors[:password]).to eq(['is too short', 'is too weak'])
    end

    it 'handles nil values' do
      # When value is nil, array_wrap returns [], and add doesn't create the key
      errors.add_multiple_errors(name: nil)
      expect(errors[:name]).to be_nil
      expect(errors.keys).not_to include(:name)
    end

    it 'merges with existing errors' do
      errors.add(:name, 'is required')
      errors.add_multiple_errors(name: 'is too short', email: 'is invalid')
      expect(errors[:name]).to eq(['is required', 'is too short'])
      expect(errors[:email]).to eq(['is invalid'])
    end
  end

  describe '#each' do
    it 'iterates over each field and message pair' do
      errors.add(:name, 'is required')
      errors.add(:email, 'is invalid')
      errors.add(:email, 'is required')

      results = []
      errors.each { |field, message| results << [field, message] }

      expect(results).to contain_exactly(
        [:name, 'is required'],
        [:email, 'is invalid'],
        [:email, 'is required']
      )
    end

    it 'handles empty errors' do
      results = []
      errors.each { |field, message| results << [field, message] }
      expect(results).to be_empty
    end
  end

  describe '#full_messages' do
    it 'formats errors with capitalized attribute names' do
      errors.add(:user_name, 'is required')
      errors.add(:email, 'is invalid')
      expect(errors.full_messages).to contain_exactly(
        'User_name is required',
        'Email is invalid'
      )
    end

    it 'handles dot-separated attribute names' do
      errors.add('user.name', 'is required')
      expect(errors.full_messages).to eq(['User_name is required'])
    end

    it 'returns base messages without attribute prefix' do
      errors.add(:base, 'Something went wrong')
      expect(errors.full_messages).to eq(['Something went wrong'])
    end

    it 'handles multiple errors for same attribute' do
      errors.add(:password, 'is required')
      errors.add(:password, 'is too short')
      expect(errors.full_messages).to contain_exactly(
        'Password is required',
        'Password is too short'
      )
    end

    it 'returns empty array when no errors' do
      expect(errors.full_messages).to eq([])
    end
  end
end

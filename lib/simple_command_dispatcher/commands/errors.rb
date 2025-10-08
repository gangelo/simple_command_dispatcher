# frozen_string_literal: true

require_relative 'utils'

module SimpleCommandDispatcher
  module Commands
    module CommandCallable
      # Raised when a command's call method is not implemented
      class NotImplementedError < ::StandardError; end

      # Error collection for CommandCallable commands.
      # Stores validation errors as a hash where keys are field names and values are arrays of error messages.
      class Errors < Hash
        # Adds an error message to the specified field.
        # Automatically prevents duplicate messages for the same field.
        #
        # @param key [Symbol, String] the field name
        # @param value [String] the error message
        # @param _opts [Hash] reserved for future use
        # @return [Array] the updated array of error messages for this field
        #
        # @example
        #   errors.add(:email, 'is required')
        #   errors.add(:email, 'is invalid')
        #   errors[:email] # => ['is required', 'is invalid']
        def add(key, value, _opts = {})
          self[key] ||= []
          self[key] << value
          self[key].uniq!
        end

        # Adds multiple errors from a hash.
        # Values can be single messages or arrays of messages.
        #
        # @param errors_hash [Hash] hash of field names to error message(s)
        #
        # @example
        #   errors.add_multiple_errors(email: 'is required', password: ['is too short', 'is too weak'])
        def add_multiple_errors(errors_hash)
          errors_hash.each do |key, values|
            CommandCallable::Utils.array_wrap(values).each { |value| add key, value }
          end
        end

        # Iterates over each field and message pair.
        # If a field has multiple messages, yields once for each message.
        #
        # @yieldparam field [Symbol] the field name
        # @yieldparam message [String] the error message
        #
        # @example
        #   errors.each { |field, message| puts "#{field}: #{message}" }
        def each
          each_key do |field|
            self[field].each { |message| yield field, message }
          end
        end

        # Returns an array of formatted error messages.
        # Messages are prefixed with the capitalized field name, except for :base.
        #
        # @return [Array<String>] formatted error messages
        #
        # @example
        #   errors.add(:email, 'is required')
        #   errors.add(:base, 'Something went wrong')
        #   errors.full_messages # => ['Email is required', 'Something went wrong']
        def full_messages
          map { |attribute, message| full_message(attribute, message) }
        end

        private

        def full_message(attribute, message)
          return message if attribute == :base

          attr_name = attribute.to_s.tr('.', '_').capitalize
          "#{attr_name} #{message}"
        end
      end
    end
  end
end

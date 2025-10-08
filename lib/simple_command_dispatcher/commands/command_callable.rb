# frozen_string_literal: true

require_relative 'errors'

module SimpleCommandDispatcher
  module Commands
    # CommandCallable provides a standardized interface for command objects with built-in
    # success/failure tracking and error handling.
    #
    # When prepended to a command class, it:
    # - Adds a class-level `.call` method that instantiates and executes the command
    # - Tracks command execution with `success?` and `failure?` methods
    # - Provides error collection via the `errors` object
    # - Stores the command's return value in `result`
    #
    # @example Basic usage
    #   class AuthenticateUser
    #     prepend SimpleCommandDispatcher::Commands::CommandCallable
    #
    #     def initialize(email:, password:)
    #       @email = email
    #       @password = password
    #     end
    #
    #     def call
    #       return nil unless user = User.find_by(email: @email)
    #       return nil unless user.authenticate(@password)
    #
    #       user
    #     end
    #   end
    #
    #   command = AuthenticateUser.call(email: 'user@example.com', password: 'secret')
    #   command.success? # => true if user found and authenticated
    #   command.result   # => User object or nil
    module CommandCallable
      # @return [Object] the return value from the command's call method
      attr_reader :result

      module ClassMethods
        # Creates a new instance of the command and calls it, passing all arguments through.
        #
        # @param args [Array] positional arguments passed to initialize
        # @param kwargs [Hash] keyword arguments passed to initialize
        # @return [Object] the command instance (not the result - use .result to get the return value)
        def call(...)
          new(...).call
        end
      end

      def self.prepended(base)
        base.extend ClassMethods
      end

      # Executes the command by calling super (your command's implementation).
      # Tracks execution state and stores the result.
      #
      # @return [self] the command instance for method chaining
      # @raise [NotImplementedError] if the including class doesn't define a call method
      def call
        raise NotImplementedError unless defined?(super)

        @called = true
        @result = super

        self
      end

      # Returns true if the command was called successfully (no errors).
      #
      # @return [Boolean] true if called and no errors present
      def success?
        called? && !failure?
      end
      alias successful? success?

      # Returns true if the command was called but has errors.
      #
      # @return [Boolean] true if called and errors are present
      def failure?
        called? && errors.any?
      end

      # Returns the errors collection for this command.
      # If the command class defines its own errors method, that will be used instead.
      #
      # @return [Errors] the errors collection
      def errors
        return super if defined?(super)

        @errors ||= Errors.new
      end

      private

      # Returns true if the command's call method has been invoked.
      #
      # @return [Boolean] true if call has been invoked
      def called?
        @called ||= false
      end
    end
  end
end

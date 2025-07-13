# frozen_string_literal: true

require_relative 'errors'

module SimpleCommandDispatcher
  module Commands
    module CommandCallable
      attr_reader :result

      module ClassMethods
        # Accept everything, essentially: `call(*args, **kwargs)``
        def call(...)
          new(...).call
        end
      end

      def self.prepended(base)
        base.extend ClassMethods
      end

      def call
        raise NotImplementedError unless defined?(super)

        @called = true
        @result = super

        self
      end

      def success?
        called? && !failure?
      end
      alias successful? success?

      def failure?
        called? && errors.any?
      end

      def errors
        return super if defined?(super)

        @errors ||= Errors.new
      end

      private

      def called?
        @called ||= false
      end
    end
  end
end

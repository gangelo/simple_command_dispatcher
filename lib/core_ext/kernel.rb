# frozen_string_literal: true

module Kernel
  # Returns the eigenclass (singleton class) of the current object.
  # This allows classes to reference their own class-level methods and variables.
  #
  # @return [Class] the eigenclass of the current object
  #
  # @example
  #   class MyClass
  #     def self.test
  #       eigenclass
  #     end
  #   end
  #   MyClass.test # => #<Class:MyClass>
  #
  def eigenclass
    class << self
      self
    end
  end
end

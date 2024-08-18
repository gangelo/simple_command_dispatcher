# frozen_string_literal: true

module Kernel
  # Define an eigenclass method for the Kernel module so that classes can
  # reference themselves at the class level.
  def eigenclass
    class << self
      self
    end
  end
end

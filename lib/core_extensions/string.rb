# frozen_string_literal: true

class String
  # Returns a copy of string with all spaces removed.
  #
  # @return [String] with all spaces trimmed which includes all leading, trailing and embedded spaces.
  def trim_all
    gsub(/\s+/, '')
  end
end

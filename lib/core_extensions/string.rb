class String
	# Returns a copy of string with all spaces removed.
	#   
	# @return [String] with all spaces trimmed which includes all leading, trailing and embedded spaces.
   def trim_all
      self.gsub(/\s+/, "")
   end
end
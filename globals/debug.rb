def dump(v, type = "ex")
	print v.inspect
	return raise StandardError, v.inspect if type == "ex"
	puts v
	exit
end

class Debug
	def self.reset
		@after = Hash.new
		return true
	end

	def self.after(i, scope = :global, reset = false)

		# Create the after variable if not exists
		@after = Hash.new if !@after.is_a?(Hash) || reset == 'all'

		# If the hash scope does not exist yet create it
		@after[scope] = 0 if @after[scope].nil? || reset

		# If we did reset then stop and show
		return 'reset' if reset || reset == 'all'

		# If we have reached the loop
		return true if i <= @after[scope]

		# Increase the counter
		@after[scope] += 1

		return false
	end
end
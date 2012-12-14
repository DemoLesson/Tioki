class Abtests < ActiveRecord::Base

	# Abtester method
	def self.use(slug, maxInc = 1)

		# Get the object by slug
		obj = where('`slug` = ?', slug).first
		obj = new({"slug" => slug, "maxinc" => maxInc}) if obj.nil?

		# Get the currently set increment
		currentInc = obj.inc

		# If the increment has reached the maximum (or somehow higher) reset it to 0
		if currentInc >= obj.maxinc
			obj.inc = 0
		# Otherwise increment by one
		else
			obj.inc = currentInc + 1
		end

		# Save the object
		obj.save

		# Return the original increment
		return currentInc
	end
end
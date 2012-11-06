class Favorite < ActiveRecord::Base
	belongs_to :user

	def model!

		# Return the object in question
		begin; return _map!(self.model)
		
		# If the object that was favorited does not exist delete the favorite
		rescue ActiveRecord::RecordNotFound => e
			self.destroy
			return nil
		end
	end

	def model?(*classes)

		# Get model
		comp = model!

		# IDK why i have to use this
		comp = comp.class.name unless comp.is_a?(String)

		# Get model class name
		comp = comp.split(':').first

		# Is the model any of the following
		classes.each do |_class|
			_class = _class.to_s if _class.is_a?(Symbol)

			# If the comparision is true
			return true if comp.downcase == _class.downcase
		end

		# Return false
		return false
	end
end

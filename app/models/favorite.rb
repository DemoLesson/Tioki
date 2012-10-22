class Favorite < ActiveRecord::Base
	belongs_to :user

	def model(sup = false)
		begin
			return super() if sup
			return _map!(super()) unless sup
		rescue ActiveRecord::RecordNotFound =>
			self.destroy
			return nil
		end
	end

	def model?(*classes)

		# Get model
		comp = model(true)

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

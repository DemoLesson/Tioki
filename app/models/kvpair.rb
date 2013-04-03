class Kvpair < ActiveRecord::Base
	def map_tag
		# Return the object in question
		begin; return mapTag!(self.owner)
		
		# If the notifiable object does not exist destroy the notification
		rescue ActiveRecord::RecordNotFound
			self.destroy
			return nil
		end
	end

	def map_id
		_, id = self.owner.split(":")
		id
	end
end

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

	def job_within?(job)
		#Formatted As Location:Point1Lat,Point1Long,Point2Lat,Point2Long
		_, box = self.value.split(":")
		lat1, long1, lat2, long2 = box.split(",")

		job.latitude > lat1 && job_latitude < lat2 && job.longitude > long1 && job.longitude < long2
	end
end

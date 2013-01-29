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

	def self.seeking_location_box(location)
		address = Geocoder::search(location).first

		if address
			if address.geometry.bounds
				coords = address.geometry.bounds.values.collect { |coord| [coord.lat, coord.lng] }
			else
				#Some things do not have a bounding box given by google
				coords = address.geometry.viewport.values.collect { |coord| [coord.lat, coord.lng] }
			end

			#get distance for bounding box
			distance = Geocoder::Calculations.distance_between(coords.first, coords.last)

			box = Geocoder::Calculations.bounding_box(address.geometry.location.values, distance)
			return box
		else
			return nil
		end
	end
end

class JobSeeker < ActiveRecord::Base
  attr_accessible :any_location, :box, :grade_ids, :location, :school_type, :subject_ids, :user_id

	def job_within?(job)
		#Formatted As Location:Point1Lat,Point1Long,Point2Lat,Point2Long
		lat1, long1, lat2, long2 = self.box.split(",")

		if job.group.latitude && job.group.longitude
			job.group.latitude > lat1.to_f && job.group.latitude < lat2.to_f && job.group.longitude > long1.to_f && job.group.longitude < long2.to_f
		else
			false
		end
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

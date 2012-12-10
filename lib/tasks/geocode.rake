require 'rubygems'

namespace :geocode do
  desc "Migrate school gps data to jobs"
  task :jobs => :environment do
    @jobs = Job.all
    @jobs.each do |job|
      job.latitude = job.school.latitude
      job.longitude = job.school.longitude
      job.save
    end
  end

  desc "Set users coordinates and country,state,city"
  task :users =>:environment do
	  users = User.where("location is not null")
	  users = users.select{|user| user.location.present? }

	  users.each do |user|
		  #coordinates
		  user.geocode

		  #country,state,location
		  user.reverse_geocode
	  end
  end
end

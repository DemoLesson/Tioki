desc "Merge teachers into users."
task :video_details => :environment do
	Video.where("output_url like 'ext%'").each do |video|
		if video.name.empty?
			video.name = video.details["title"]
		end
		video.thumbnail_url = video.details["thumbnail_url"]
		video.save
	end
end


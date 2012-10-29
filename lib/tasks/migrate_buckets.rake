desc "Connect EVERYONE to the Tioki technology."
task :migrate_buckets => :environment do
	Video.all.each do |v|
		video = v.output_url
		begin
			next if video.nil? || video.empty?
			bucket = Regexp.new("http://s3.amazonaws.com/([a-zA-Z]+)/").match(video)[1]
			next if bucket.nil? || bucket.empty?
			v.update_attribute(:output_url, video.gsub(bucket, 'tioki-video-encoded'))
		rescue => e
			raise e
		end
	end
end
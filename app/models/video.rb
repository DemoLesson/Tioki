class Video < ActiveRecord::Base
	belongs_to :teacher # Migration
	belongs_to :user
	has_many :video_views

	# Video Skills
	has_and_belongs_to_many :skills, :join_table => 'videos_skills'
	belongs_to :application

	mount_uploader :video, VideoUploader

	scope :finished, :conditions => {:encoded_state => "finished"}

	after_create :set_details

	def set_details
		if external?
			self.thumbnail_url = details["thumbnail_url"]
			self.name = details["title"]
			self.save
		end
	end

	# Encode a new video
	def encode
		begin

			# Set I/O file names
			input = "s3://DemoLessonVideo/#{self.secret_url}"
			output = "s3://tioki-video-encoded/#{self.id}-#{Time.now.to_i}.mp4"
			thumbnails = "s3://tioki-video-encoded/#{self.id}-#{Time.now.to_i}/"

			# Create a new zencoder job
			zen = Zencoder::Job.create({
										   :api_key => 'ebbcf62dc3d33b40a9ac99e623328583',
										   :input => input,
										   :outputs => [
											   {
												   :label => self.id.to_s,
												   :public => true,
												   :url => output,
												   :thumbnails => {
													   :number => 5,
													   :size => "640x480",
													   :base_url => thumbnails
												   }
											   }
										   ]
									   })

			# Save the output url, job id, and encoded state
			self.output_url = zen.body['outputs'][0]['url']
			self.job_id = zen.body['id'].to_s
			self.encoded_state = "queued"

			# Save the model
			self.save!

				# Rescue any errors
		rescue RuntimeError => exception
			errors.add_to_base("Video encoding request failed with result: " + exception.to_s)
			nil
		end
	end

	# Encode a new snippet
	def snippet_encode(time)
		begin

			# Set I/O file names
			input = "s3://DemoLessonVideo/#{self.secret_url}"
			output = "s3://tioki-video-encoded/#{self.id}-#{Time.now.to_i}.mp4"
			thumbnails = "s3://tioki-video-encoded/#{self.id}-#{Time.now.to_i}/"

			# Create a new zencoder job
			zen = Zencoder::Job.create({
										   :api_key => 'ebbcf62dc3d33b40a9ac99e623328583',
										   :input => input,
										   :outputs => [
											   {
												   :label => self.id.to_s,
												   :public => true,
												   :url => output,
												   :clip_length => "00:00:30.0",
												   :start_clip => time,
												   :thumbnails => {
													   :number => 5,
													   :size => "640x580",
													   :base_url => thumbnails
												   }
											   }
										   ]
									   })

			# Save the output url, job id, and encoded state
			self.output_url = zen.body['outputs'][0]['url']
			self.job_id = zen.body['id'].to_s
			self.encoded_state = "queued"

			# Save the model
			self.save!

				# Rescue any errors
		rescue RuntimeError => exception
			errors.add_to_base("Video encoding request failed with result: " + exception.to_s)
			nil
		end
	end

	# Get the job status
	def job_status
		if self.encoded_state != 'finished'
			status = Zencoder::Job.progress(self.job_id, :api_key => 'ebbcf62dc3d33b40a9ac99e623328583')

			# Video is not available
			if status.code.to_i != 200

				short = "Zencoder Job: #{self.job_id} returned `#{status.code}`."
				unless NOTIFY.nil?
					NOTIFY.notify!(
						:short_message => short, :full_message => status.body,
						:level => 4, :file => __FILE__, :line => __LINE__
					)
				else
					Rails.logger.error(short)
				end

				status = 'unavailable'
			else
				status = status.body.state
			end

			# Update the encoded state
			if self.encoded_state != status
				self.encoded_state = status
				self.save!
			end

			# Return the status
			return status
		end

		return self.encoded_state
	end

	# # # # # # # # #
	# Is this necessary consider deprecating
	#
	# def capture_notification(output)
	#     self.encoded_state = output[:state]
	#     if self.encoded_state == "finished"
	#       self.output_url = output[:url]
	#       self.thumbnail = open(URI.parse("http://" + zencoder_setting["s3_output"]["bucket"] + ".s3.amazonaws.com/thumbnails_#{self.id}/frame_0000.png"))
	#       self.thumbnail_content_type = "image/png"
	#       # get the job details so we can retrieve the length of the video in milliseconds
	#       zen = Zencoder.new
	#       self.duration_in_ms = zen.details(self.job_id)["job"]["output_media_files"].first["duration_in_ms"]
	#     end
	#     self.save
	#   end
	# # # # # # # # #

	# a handy way to turn duration_in_ms into a formatted string like 5:34
	def human_length
		if duration_in_ms
			minutes = duration_in_ms / 1000 / 60
			seconds = (duration_in_ms / 1000) - (minutes * 60)
			sprintf("%d:%02d", minutes, seconds)
		else
			"Unknown"
		end
	end

	# # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # #

	# Get the name of the video
	def name(empty = "Untitled")
		# Get the name
		name = super()

		# Return the name is it is not empty
		name.nil? || name.empty? ? empty.html_safe : ERB::Util.html_escape(name).html_safe
	end

	# Get the name of the video
	def description(empty = "No description...")

		# Get the description
		description = super()

		# If there is no local description then display unavailable for external videos
		return "Description unavailable for external videos." if external? && (description.nil? || description.empty?)

		# Return the name is it is not empty
		description.nil? || description.empty? ? empty.html_safe : ERB::Util.html_escape(description).html_safe
	end

	# Thumbnails
	def thumbnail
		unless external?
			begin
				thumbnail_url = self.output_url[0...-4] + '/frame_0001.png'
				raise StandardError unless HTTParty.get(thumbnail_url).code == 200
				return thumbnail_url
			rescue
				return "tioki/icons/play-icon.png"
			end
		end

		self.thumbnail_url
	end

	# Get the embed code for the video
	def embed_code(width = nil, height = nil, output_url = nil, wrapper = true)

		# Default scale
		width = 640 if width.nil?
		height = 480 if height.nil?

		# Make sure we got a URL
		output_url = self.output_url if output_url.nil?

		# If the url is external
		if !output_url.nil? && output_url[0...3] == 'ext'

			# Get the API Response
			response = details(width, height, output_url, wrapper)

			begin
				# Return HTML Embed Code
				return response["html"].html_safe
			rescue
				self.destroy
				return nil
			end
		end

		if job_status == 'finished'

			# HTML 5 Embed Code
			embed = <<-EMBED
      <video id="my_video_1" class="video-js vjs-default-skin" controls preload="auto" width="#{width}" height="#{height}" data-setup="{}">
        <source src="#{output_url}" type='video/mp4'>
      </video>
			EMBED

			# Return HTML Embed Code
			return embed.html_safe
		elsif job_status == 'unavailable'

			# Return status
			return "<p class=\"processing\">There was a problem getting the requested video. Please let us know with the blue box in the corner and refererence the page you are on.</p>".html_safe
		else

			# Return status
			return "<p class=\"processing\">The video is currently being processed for web viewage. Please check back in a bit.</p>".html_safe
		end
	end

	# This calls noembed returns no change if the url is local
	def details(width = 640, height = 480, output_url = nil, wrapper = true)

		# Make sure we got a URL
		output_url = self.output_url if output_url.nil?

		if !output_url.nil? && output_url[0...3] == 'ext'
			output_url = output_url[4..-1]

			# Query noembed
			query = {
				:url => output_url,
				:maxwidth => width,
				:maxheight => height,
			}

			# Should we wrap the embed?
			query[:nowrap] = :on unless wrapper

			return HTTParty.get("http://noembed.com/embed", {
				:query => query
			})
		end

		return output_url
	end

	# Is video external to tioki
	def external?
		return false if self.output_url.nil? || self.output_url.empty?
		self.output_url[0...3] == 'ext' ? true : false
	end

	# Cleanup
	def cleanup
	end

	# Private methods below
	private

	def zencoder_setting
		@zencoder_config ||= YAML.load_file("#{Rails.root}/config/zencoder.yml")
	end

	def video_changed?
		return false
	end

end

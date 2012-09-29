class Video < ActiveRecord::Base
  belongs_to :teacher
  has_many :video_views
  
  mount_uploader :video, VideoUploader
  
  scope :finished, :conditions => { :encoded_state => "finished" }
  
  # Encode a new video
  def encode
    begin

      # Set I/O file names
      input = "s3://DemoLessonVideo/#{self.secret_url}"
      output = "s3://DLEncodedVideo/#{self.id}-#{Time.now.to_i}.mp4"

      # Create a new zencoder job
      zen = Zencoder::Job.create({
        :api_key => 'ebbcf62dc3d33b40a9ac99e623328583',
        :input => input,
        :outputs => [
          {
            :label => self.id.to_s,
            :public => true,
            :url => output
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
      output = "s3://DLEncodedVideo/#{self.id}-#{Time.now.to_i}.mp4"

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
            :start_clip => time
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
    status = Zencoder::Job.progress(self.job_id, :api_key => 'ebbcf62dc3d33b40a9ac99e623328583').body.state

    # Update the encoded state
    if self.encoded_state != status
      self.encoded_state = status
      self.save!
    end

    return status
  end
  
  # # # # # # # # #
  # Is this necessary consider deprecating
  #
  # def capture_notification(output)
  #     self.encoded_state = output[:state]
  #     if self.encoded_state == "finished"
  #       self.output_url = output[:url]
  #       self.thumbnail = open(URI.parse("http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails_#{self.id}/frame_0000.png"))
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

    # If external video
    return details["title"] if external?

    # Get the name
    name = super()

    # Return the name is it is not empty
    name.nil? || name.empty? ? empty.html_safe : name.html_safe
  end

  # Get the name of the video
  def description(empty = "No description...")

    # Get the description
    description = super()

    # If there is no local description then display unavailable for external videos
    return "Description unavailable for external videos." if external? && (description.nil? || description.empty?)

    # Return the name is it is not empty
    description.nil? || description.empty? ? empty.html_safe : description.html_safe
  end

  # Thumbnails
  def thumbnail
    return "tioki/icons/play-icon.png" unless external?

    details["thumbnail_url"]
  end

  # Get the embed code for the video
  def embed_code(width = 640, height = 480, output_url = nil)

    # Make sure we got a URL
    output_url = self.output_url if output_url.nil?

    # If the url is external
    if output_url[0...3] == 'ext'

      # Get the API Response
      response = details(width, height, output_url)
      
      # Return HTML Embed Code
      #dump response
      return response["html"].html_safe
    end

    unless job_status == 'finished'
      # Return status
      return "<p class=\"processing\">The video is currently being processed for web viewage. Please check back in a bit.</p>".html_safe
    else
      # HTML 5 Embed Code
      embed = <<-EMBED
      <video id="my_video_1" class="video-js vjs-default-skin" controls preload="auto" width="#{width}" height="#{height}" data-setup="{}">
        <source src="#{output_url}" type='video/mp4'>
      </video>
      EMBED

      # Return HTML Embed Code
      return embed.html_safe
    end
  end

  # This calls noembed returns no change if the url is local
  def details(width = 640, height = 480, output_url = nil)

    # Make sure we got a URL
    output_url = self.output_url if output_url.nil?

    if output_url[0...3] == 'ext'
      output_url = output_url[4..-1]

      # Query noembed
      return HTTParty.get("http://noembed.com/embed", {
        :query => {
          :url => output_url,
          :maxwidth => width,
          :maxheight => height
        }
      })
    end

    return output_url
  end

  # Is video external to tioki
  def external?
    output_url[0...3] == 'ext' ? true : false
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

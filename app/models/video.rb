class Video < ActiveRecord::Base
  belongs_to :teacher
  has_many :video_views
  
  mount_uploader :video, VideoUploader
  
  scope :finished, :conditions => { :encoded_state => "finished" }

  #has_attached_file :attached_video,
  #  :url => ":class/:id/:style/:basename.:extension",
  #  :path => ":class/:id/:style/:basename.:extension",
  #  :storage => :s3,
  #  :s3_credentials => "#{Rails.root}/config/amazon_s3.yml"
  #validates_attachment_presence :attached_video
  
  has_attached_file :thumbnail, :styles => {:thumb => "162x161>"}

  #after_destroy :remove_encoded_video

  def encode

    unless self.video.url.nil?
      # Get the S3 Location
      matches = /(https|http):\/\/s3.amazonaws.com\/([_\-\w]*)\//.match(self.video.url)

      # Get Protocol and Bucket
      protocol = matches[1]
      bucket = matches[2]

      # Get the S3 URL for zencoder
      video = self.video.url.gsub(matches, 's3://' + bucket + '/')

      # Make the timestamps for unique (For Development Purposes)
      output = 's3://DLEncodedVideo/' + self.id.to_s + '-' + Time.now.to_i.to_s + '.mp4'
    else
      # For Direct Uploads
      video = "s3://DemoLessonVideo/" + self.secret_url
      output = 's3://DLEncodedVideo/' + self.id.to_s + '-' + Time.now.to_i.to_s + '.mp4'
    end

    begin

      # Create a ZenCoder Job
      zen = Zencoder::Job.create({
        :api_key => 'ebbcf62dc3d33b40a9ac99e623328583',
        :input => video,
        :outputs => [{
          :label => self.id.to_s,
          :public => true,
          :url => output
        }]
      })

      # Mark the job as queued
      self.encoded_state = "queued"

      # Set the output url
      self.output_url = zen.body['outputs'][0]['url']

      # Set the job
      self.job_id = zen.body['id'].to_s

      # Save
      self.save!

      status

    rescue RuntimeError => exception
      errors.add_to_base("Video encoding request failed with result: " + exception.to_s)
      nil
    end
  end

  def status
    #dump Zencoder::Job.progress(self.job_id, :api_key => 'ebbcf62dc3d33b40a9ac99e623328583').inspect
  end

  def snippet_encode(time)
    begin
      zen = Zencoder::Job.create({:api_key => 'ebbcf62dc3d33b40a9ac99e623328583', :input => "s3://DemoLessonVideo/" + self.secret_url, :outputs => [{:label => self.id.to_s, :public => true, :url => 's3://DLEncodedVideo/' + self.id.to_s + '.mp4', :clip_length => "00:00:30.0", :start_clip => time }]})
      self.encoded_state = "queued"      
      self.output_url = zen.body['outputs'][0]['url']
      self.job_id = zen.body['id'].to_s
      self.save!
      #else
      #  errors.add_to_base(zen.errors)
      #  nil
      #end
    rescue RuntimeError => exception
      errors.add_to_base("Video encoding request failed with result: " + exception.to_s)
      nil
    end
  end

  def remove_encoded_video
    unless output_url.blank?
      AWS::S3::Base.establish_connection!(
        :access_key_id     => zencoder_setting["s3_output"]["access_key_id"],
        :secret_access_key => zencoder_setting["s3_output"]["secret_access_key"]
      )
      AWS::S3::S3Object.delete(File.basename(output_url), zencoder_setting["s3_output"]["bucket"])
      AWS::S3::S3Object.delete("/thumbnails_#{self.id}/frame_0000.png", zencoder_setting["s3_output"]["bucket"])
    end
  end
  
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
    name.nil? || name.empty? ? empty.html_safe : name.html_safe
  end

  # Get the name of the video
  def description(empty = "No description...")

    # Get the description
    description = super()

    # Return the name is it is not empty
    description.nil? || description.empty? ? empty.html_safe : description.html_safe
  end

  # Get the embed code for the video
  def embed_code(width = 640, height = 480, output_url = nil)

    # Make sure we got a URL
    output_url = self.output_url if output_url.nil?

    # If the url is external
    if output_url[0...3] == 'ext'
      output_url = output_url[4..-1]

      response = HTTParty.get("http://noembed.com/embed", {
        :query => {
          :url => output_url,
          :maxwidth => width,
          :maxheight => height
        }
      })
      json = JSON.parse response.body
    
      # Return HTML Embed Code
      return json["html"].html_safe
    end

    # Return HTML Embed Code
    return "<video width=\"#{width}\" height=\"#{height}\" src=\"#{output_url}\" controls preload></video>".html_safe
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

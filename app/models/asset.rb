class Asset < ActiveRecord::Base
  belongs_to :teacher
  
  validates_presence_of :name, :file, :alert => 'You need to select a file to upload and enter the document name.'
  
  has_attached_file :file,
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                    :url  => '/assets/:basename.:extension',
                    :path => 'assets/:basename.:extension',
                    :bucket => 'DemoLessonS3'
                    #add validation !!
                    
                    
  before_create :randomize_file_name
  
private

  def randomize_file_name
    extension = File.extname(file_file_name).downcase
    self.file.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}_#{file_file_name}")
  end
  
end

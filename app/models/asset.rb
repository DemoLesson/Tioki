class Asset < ActiveRecord::Base
	belongs_to :teacher # Migration
	belongs_to :user
	belongs_to :application
	belongs_to :job

	validates_presence_of :name, :file, :alert => 'You need to select a file to upload and enter the document name.'

	has_attached_file :file,
		:storage => :fog,
		:fog_credentials => {
			:provider => 'AWS',
			:aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
			:aws_secret_access_key  => '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',
			:region => 'us-west-2'
		},
		:fog_public => true,
		:fog_directory => 'tioki',
		:path => 'assets/:basename.:extension'

	before_create :randomize_file_name
	before_destroy :delete_file

	private

		def randomize_file_name
			extension = File.extname(file_file_name).downcase
			self.file.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}_#{file_file_name}")
		end

		# Delete file off S3
		def delete_file
			self.file.destroy
		end
end

class Asset < ActiveRecord::Base
	belongs_to :teacher
	belongs_to :job
	belongs_to :application

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

		private

		def randomize_file_name
			extension = File.extname(file_file_name).downcase
			self.file.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}_#{file_file_name}")
		end
end

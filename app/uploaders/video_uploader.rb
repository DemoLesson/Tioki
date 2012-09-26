class VideoUploader < CarrierWave::Uploader::Base
	include CarrierWaveDirect::Uploader
	storage :fog

	def move_to_cache
		true
	end
	def move_to_store
		true
	end
	def cache_dir
  		"#{Rails.root}/tmp/uploads"
	end
	def store_dir
		'uploads/' + Time.now.strftime('%Y_%m_%d_%H_%M_%S')
	end
end

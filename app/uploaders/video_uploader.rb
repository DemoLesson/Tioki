class VideoUploader < CarrierWave::Uploader::Base
	#include CarrierWaveDirect::Uploader
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
end

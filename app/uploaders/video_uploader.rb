class VideoUploader < CarrierWave::Uploader::Base
	include CarrierWaveDirect::Uploader
	storage :fog
end

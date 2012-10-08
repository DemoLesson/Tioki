class VideoUploader < CarrierWave::Uploader::Base
	include CarrierWaveDirect::Uploader
	storage :s3
end

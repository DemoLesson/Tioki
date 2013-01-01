require 'rubygems'
require 'open-uri'

namespace :code do
	desc "Generate 500 beta codes"
	task :generate => :environment do
		3000.times do
			@passcode = Passcode.new
			uuid = UUIDTools::UUID.random_create
			@passcode.code = uuid.to_s
			@passcode.save
			puts uuid.to_s
		end
	end
end
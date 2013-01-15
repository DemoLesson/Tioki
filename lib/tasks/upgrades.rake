namespace :upgrade do
	desc "Use link targeting for all whiteboard links."
	task :whiteboard_link_targeting => :environment do
		total = Whiteboard.count
		Whiteboard.all.each_with_index do |w, i|
			puts "Processing Whiteboard #{i+1}/#{total}"

			links = Regexp.new("<a .*>(.*)<\/a>")
			message = w.message.gsub(links, '\1')

			# Extract links from the message
			addData = Hash.new
			addData["urls"] = Array.new
			message.scan(URI.regexp(['http', 'https'])) do |*m|
				addData["urls"] << $&
			end

			# Create links and screenshots
			addData["urls"].each do |u|

				# If the url is not on tioki.com then add target _blank to the anchor
				attrs = ''; attrs = "target=\"_blank\"" if u.match(Regexp.new("^(http|https)://(.*\.|)tioki\.com.*$")).nil?
				message = message.gsub("#{u}", "<a href=\"#{u}\" #{attrs}>#{u}</a>")
			end

			# update message
			w.update_attribute(:message, message)
		end
	end
end
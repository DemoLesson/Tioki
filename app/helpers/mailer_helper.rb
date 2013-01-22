module MailerHelper
	def mail_link(link, color = '2AA99B')

		# Fix the url to an absolute one if not already done
		tioki_link = Regexp.new('^(http|https)://(.*\.|)tioki\.com.*$')
		link = link.gsub(' href="/', ' href="http://tioki.com/') if link.match(tioki_link).nil?

		# Get the attributes already in the link
		find_attrs = Regexp.new('(\S+)=["\']?((?:.(?!["\']?\s+(?:\S+)=|[>"\']))+.)["\']?')
		attrs_hash = link.scan(find_attrs).inject({}) {|hash, (k, v)| hash[k] = v; hash}
		orig_attrs = link.scan(find_attrs).inject([]){|r, (k, v)| r << "#{k}=\"#{v}\""}.join(' ')

		if attrs_hash['style'].nil?

			# Add a stye tag
			attrs_hash['style'] << "color:#{color};"
		else

			# Change the color of the links (if a style attribute exists)
			find_color = Regexp.new('color:(#[\\dA-F]{3,6}|rgb[a]*\\([0-9]{1,3},[0-9]{1,3},[0-9]{1,3}(,[0-9\\.]{1,3}|)\\))[;]*')
			if (color_match = attrs_hash['style'].match(find_color)).nil?

				# Add color
				attrs_hash['style'] << "color:#{color};"
			else

				# Replace the color
				attrs_hash['style'] = attrs_hash['style'].gsub(color_match[0], '')
				attrs_hash['style'] << "color:##{color};"
			end
		end

		# Replace the attributes
		link = link.gsub(orig_attrs, attrs_hash.inject([]){|r, (k, v)| r << "#{k}=\"#{v}\""}.join(' ')).squeeze(' ')

		# Return the new link
		return link.html_safe
	end
end

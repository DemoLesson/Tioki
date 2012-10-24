def md5(x)
	unless x.is_a?(String)
		return x unless x.responds_to?('to_s')
		x.to_s if x.responds_to?('to_s')
	end

	# Hash it up
	Digest::MD5.hexdigest(x)
end

# Extensions to ActiveRecord
class ActiveRecord::Base
	def tag!

		# If no id then return false
		return false if self.id.nil?

		# Return the text tag
		self.class.name + ':' + self.id.to_s
	end

	def _map!(tag)

		# If tag is not a string return nil
		return nil unless tag.is_a?(String)

		# If not a tag then return nil
		return nil if tag.count(':') != 1

		# Get the class and ID
		_class, _id = tag.split(':')

		# Get the model by class and ID
		Kernel.const_get(_class).find(_id.to_i)
	end
end

def mapTag!(tag)

	# If tag is not a string return nil
	return nil unless tag.is_a?(String)

	# If not a tag then return nil
	return nil if tag.count(':') != 1

	# Get the class and ID
	_class, _id = tag.split(':')

	# Get the model by class and ID
	Kernel.const_get(_class).find(_id)
end

# Array class
class Array
	def eachX(times, misc = nil, done = 1)
		return Array.new if times < 1

		# Run normal each
		returned = Array.new
		self.each do |val|
			returned << yield(done, val)
		end

		return returned if misc == 'break' && !returned.delete_if{|x| x.nil?}.empty?
		returned.concat(self.eachX(times - 1, misc, done + 1, &Proc.new))
	end
end

# Hash cleaner
class Hash
	def clean!
		self.delete_if do |key, val|
			if block_given?
				yield(key,val)
			else
				# Prepeare the tests
				test1 = val.nil?
				test2 = val === 0
				test3 = val === false
				test4 = val.empty? if val.respond_to?('empty?')
				test5 = val.strip.empty? if val.is_a?(String) && val.respond_to?('empty?')

				# Were any of the tests true
				test1 || test2 || test3 || test4 || test5
			end
		end

		self.each do |key, val|
			if self[key].is_a?(Hash) && self[key].respond_to?('clean!')
				if block_given?
					self[key] = self[key].clean!(&Proc.new)
				else
					self[key] = self[key].clean!
				end
			end
		end

		return self
	end

	def method_missing(name, *args)
		if name[-1] == "="
			self[name[0...-1].to_s] = args.first
		else
			ret = self[name.to_s]
			return ret.nil? ? self[name] : ret
		end
  	end

  	def collect
  		return self.to_hash unless block_given?

  		replace = Hash.new
		begin
  		self.each do |key, val|
  			returned = yield(key, val)
  			replace[key] = returned.nil? ? val : returned
  		end
		rescue
			#It is possible that some things need the enumerable version of collect 
			#when called on a hash
			return super
		end

  		return replace
  	end

  	def collect!
  		return nil unless block_given?

  		self.merge!(self.collect(&Proc.new))
  	end
end

class String

	# Grab url elements and turn into anchor links
	def url2link(attrs = {})
		return nil unless attrs.is_a?(Hash)

		# Prepare the attributes
		attributes = Array.new
		attrs.each do |key, val|
			attributes << "#{key}=\"#{val}\""
		end; attributes = attributes.join(' ')

		# Extract links from the message
		addData = Hash.new; addData["urls"] = Array.new
		self.scan(URI.regexp(['http', 'https'])) do |*m|
			addData["urls"] << $&
		end

		# Get self for gsubbing
		message = ' ' + self + ' '

		# Create links and screenshots
		addData["urls"].each do |u|
			message = message.gsub("#{u}", "<a href=\"#{u}\" #{attributes}>#{u}</a>")
		end

		return message.strip.html_safe
	end

	def tweetify(attrs = {})
		return nil unless attrs.is_a?(Hash)

		# Prepare the attributes
		attributes = Array.new
		attrs.each do |key, val|
			attributes << "#{key}=\"#{val}\""
		end; attributes = attributes.join(' ')

		# Extract hashtags from the tweet
		addData = Hash.new; addData["hashtags"] = Array.new
		self.scan(/(?:(?<=\s)|^)#(\w*[A-Za-z_]+\w*)/) do |*m|
			addData["hashtags"] << $&
		end

		# Extract @mentions from the tweet
		addData["usernames"] = Array.new
		self.scan(/@([A-Za-z0-9_]+)[:]*/) do |*m|
			addData["usernames"] << $&
		end

		# Get self for gsubbing
		message = ' ' + self + ' '

		# Create hashtags links
		addData["hashtags"].each do |u|
			url = "http://twitter.com/search/?src=hash&q=%23#{u[1..-1]}"
			message = message.gsub(" #{u} ", " <a href=\"#{url}\" #{attributes}>#{u}</a> ")
		end

		# Create mention links
		addData["usernames"].each do |u|
			user = /@([A-Za-z0-9_]+)[:]*/.match(u)[1]
			message = message.gsub(u, "<a href=\"http://twitter.com/#{user}\" #{attributes}>#{u}</a>")
		end

		return message.strip.html_safe
	end

	def numeric?
  		self.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
	end
end

class NilClass
	def empty?
		true
	end
end

# Determine if a domain uses google mail
require 'dnsruby'
def is_gmail(check)
	email = /.*@(.*)$/
	gmail = /(.google.com.|.googlemail.com.)$/
	
	match = email.match(check)

	# If there is a match then get the first captures
	unless match.nil?
		match = match.captures.first

	# Otherwise return false (It's not an email)
	else
		return false
	end

	# If there was not data matched
	return false if match.nil? || match.empty?

	# If the emails are gmail then return true
	return true if match == 'gmail.com'
	return true if match == 'googlemail.com'

	# Go ahead and get the mx records
	result = Dnsruby::Resolver.new.query(match, 15)
	result = result.answer.collect {|x| x.to_s.split(" ").last }

	# If any of these records match a google mx record return true
	result.each do |x|
		return true unless gmail.match(x).nil?
	end

	# Otherwise return false
	return false
end

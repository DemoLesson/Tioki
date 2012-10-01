module AB

	# Store the language instace
	@@language = nil

	# Have a language not found exception
	class NotFound < StandardError
	end

	# The actual dirty work
	class Language
		
		# Load up the YAML file
		def initialize
			@config = "#{Rails.root}/config/ab_language.yml"
			@language = Hash.new

			if File.exists? @config
				@language = YAML.load_file(@config)
			else
				File.open(@config, 'w+') {|f| f.write(@language.to_yaml) }
			end
		end

		# Get the stack
		def getStack(abc = 'default')
			return @language[abc]
		end

		# Get a specific slug
		def getLang(slug = nil, abc = 'default')

			# Original slug
			oslug = slug

			# Get the stack
			sources = getStack abc

			# Get the slug split by the delimiter
			slug = slug.split('.')

			# By default assume singular
			plural = false

			# If this var going to be plural
			if slug.last == 'plural'
				plural = true
				slug.pop
			end

			# Get slug length and counter
			i = 0; length = slug.length

			begin
				# Loop through segments
				slug.each do |segment|

					# Traverse down the tree
					if sources.has_key?(segment)
						sources = sources[segment]
					else
						raise AB::NotFound
					end
					
					# Get the final lang or continue
					i += 1; if length == i

						# Check if the result exists
						if sources.has_key?(plural ? 'plural' : 'singular')
							return sources[plural ? 'plural' : 'singular']

						# Otherwise raise an exception
						else
							raise AB::NotFound
						end
					elsif sources.has_key?('children')

						# Check to see if a children key exists
						sources = sources['children']
					end
				end

			# Hit the override language
			rescue => e

				# Continue with overrides unless we already did
				return getLang('default', oslug) if abc != 'default'
				return nil
			end
		end
	end

	# Get a specific slug
	def self.getLang(slug = nil, abc = 'default')
		@@language = Language.new if @@language.nil?
		@@language.getLang(slug, abc)
	end
end
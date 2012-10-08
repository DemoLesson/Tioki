unless File.exists? Rails.root + '/config/ab_language.yml'
	File.open(Rails.root + '/config/ab_language.yml', 'w+') {|f| f.write(Hash.new.to_yaml) }
end
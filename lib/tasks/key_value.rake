namespace key_value do
	desc "Migrate group location to rails 3.2 key values"
	task :location => :environment do
		Group.all.each do |group|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'location', "Group:#{group.id}")
			group.location[:address] = kvpairs.where('kvpairs.key = ?', 'address').first
			group.location[:city] = kvpairs.where('kvpairs.key = ?', 'city').first
			group.location[:region] = kvpairs.where('kvpairs.key = ?', 'region').first
			group.location[:postal] = kvpairs.where('kvpairs.key = ?', 'postal').first
		end
	end
end

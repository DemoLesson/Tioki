desc "Connect EVERYONE to the Tioki technology."
task :add_tioki_to_all => :environment do
	User.all.each do |user|
    	technology = TechnologyUser.find(:first, :conditions => ['user_id = ? && technology_id = ?', user.id, 15])
    	TechnologyUser.create(:user => user, :technology_id => 15) if technology.nil?
	end
end
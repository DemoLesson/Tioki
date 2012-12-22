desc "Connect EVERYONE to the Tioki technology."
task :add_tioki_to_all => :environment do
	User.all.each do |user|
    	technology = TechnologyUser.where('user_id = ? && technology_id = ?', user.id, 15).first
    	TechnologyUser.create(:user => user, :technology_id => 15) if technology.nil?
	end
end
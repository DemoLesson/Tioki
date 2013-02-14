desc "Migrate school gps data to jobs"
task :migrate_assets => :environment do
	#job assets
	Asset.where("job_id is not null AND assetType = 0").each do |asset|
		asset.owner_id = asset.job_id
		asset.owner_type = "Job"
		asset.save
	end
	#user assets
	Asset.where("assetType = 0 AND job_id is null AND application_id is null").each do |asset|
		asset.owner_id = asset.user_id
		asset.owner_type = "User"
		asset.save
	end
	#application assets
	Asset.where("application_id is not null").each do |asset|
		asset.owner_id = asset.application_id
		asset.owner_type = "Application"
		asset.save
	end
end

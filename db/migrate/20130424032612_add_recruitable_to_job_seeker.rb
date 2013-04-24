class AddRecruitableToJobSeeker < ActiveRecord::Migration
  def change
    add_column :job_seekers, :recruitable, :boolean
  end
end

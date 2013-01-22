class AddJobSeekingToUser < ActiveRecord::Migration
  def change
    add_column :users, :job_seeking, :boolean, :default => false
  end
end

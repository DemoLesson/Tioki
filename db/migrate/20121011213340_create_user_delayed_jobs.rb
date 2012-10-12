class CreateUserDelayedJobs < ActiveRecord::Migration
  def change
    create_table :user_delayed_jobs do |t|
      t.integer :delayed_job_id
      t.integer :user_id
      t.integer :vouchee_id
      t.datetime :action_start

      t.timestamps
    end
  end
end

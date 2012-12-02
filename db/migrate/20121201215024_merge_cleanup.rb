class MergeCleanup < ActiveRecord::Migration
  def up
  	# Drop teacher ID's
  	remove_column :experiences, :teacher_id
	remove_column :educations, :teacher_id
  	remove_column :videos, :teacher_id
  	remove_column :interviews, :teacher_id
  	remove_column :awards, :teacher_id
  	remove_column :assets, :teacher_id
  	remove_column :applications, :teacher_id
  	remove_column :presentations, :teacher_id

  	# Remove M2M Columns
  	remove_column :credentials_users, :teacher_id
  	remove_column :subjects_users, :teacher_id
  	remove_column :grades_users, :teacher_id

  	# Remove old tables
  	drop_table :credentials_teachers
  	drop_table :subjects_teachers
  	drop_table :grades_teachers
  	drop_table :teachers
  end

  def down
  end
end

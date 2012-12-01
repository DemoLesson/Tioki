class MergeTeachersUsers < ActiveRecord::Migration
  def up

  	# Add slug, guestcode, location, and dashboard preference
  	add_column :users, :slug, :string
  	add_column :users, :guest_code, :string
  	add_column :users, :location, :string
  	add_column :users, :dashboard, :string
  	add_column :users, :headline, :string
  	add_column :teachers, :migrated, :boolean

  	# Migrating ID's
  	add_column :experiences, :user_id, :integer
  	add_column :educations, :user_id, :integer
  	add_column :videos, :user_id, :integer
  	add_column :subjects_teachers, :user_id, :integer # On teacher.rb
  	add_column :interviews, :user_id, :integer
  	add_column :grades_teachers, :user_id, :integer
  	add_column :credentials_teachers, :user_id, :integer
  	add_column :awards, :user_id, :integer
  	add_column :assets, :user_id, :integer
  	add_column :applications, :user_id, :integer
  	add_column :presentations, :user_id, :integer
  	# Analytics Map
  	# Whiteboard Map

  	# Cleanup columns
  	remove_column :users, :is_verified
  	remove_column :users, :verification_code
  	remove_column :users, :default_home
  	remove_column :users, :time_zone
  	remove_column :users, :emaileventreminder
  	remove_column :users, :emaileventapproved
  	remove_column :users, :emailsubscription

  	# Key value pair table
  	create_table :kvpairs do |t|
  		t.string :owner
  		t.string :namespace
  		t.string :key
  		t.string :value
  	end

    # Clone and rename tables
    execute "CREATE TABLE `credentials_users` LIKE `credentials_teachers`;"
    execute "CREATE TABLE `subjects_users` LIKE `subjects_teachers`;"
    execute "CREATE TABLE `grades_users` LIKE `grades_teachers`;"
    execute "INSERT INTO `credentials_users` SELECT * FROM `credentials_teachers`;"
    execute "INSERT INTO `subjects_users` SELECT * FROM `subjects_teachers`;"
    execute "INSERT INTO `grades_users` SELECT * FROM `grades_teachers`;"

    # Make teacher id nullable
    change_column :credentials_users, :teacher_id, :integer,  :null => true
    change_column :subjects_users, :teacher_id, :integer,  :null => true
    change_column :grades_users, :teacher_id, :integer,  :null => true
    change_column :credentials_teachers, :teacher_id, :integer,  :null => true
    change_column :subjects_teachers, :teacher_id, :integer,  :null => true
    change_column :grades_teachers, :teacher_id, :integer,  :null => true
    change_column :experiences, :teacher_id, :integer,  :null => true
    change_column :educations, :teacher_id, :integer,  :null => true
    change_column :interviews, :teacher_id, :integer,  :null => true
    change_column :grades_teachers, :teacher_id, :integer,  :null => true
    change_column :credentials_teachers, :teacher_id, :integer,  :null => true
    change_column :awards, :teacher_id, :integer,  :null => true
    change_column :assets, :teacher_id, :integer,  :null => true
    change_column :applications, :teacher_id, :integer,  :null => true
    change_column :presentations, :teacher_id, :integer,  :null => true

  	# Indexes
  	add_index :kvpairs, :key
  	add_index :kvpairs, :owner
  	add_index :kvpairs, :namespace
  	add_index :users, :slug, :unique => true

    # Run rake task
    Rake::Task['merge_teachers'].invoke
  end

  def down

  end
end

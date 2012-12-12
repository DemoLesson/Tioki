class AddApplicationIdToInterview < ActiveRecord::Migration
  def up
  	# This is irreversible
  	change_column :applications, :status, :string

  	# Interviews Renaming
  	rename_column :interviews, :date, :datetime_1
  	rename_column :interviews, :date_alternate, :datetime_2
  	rename_column :interviews, :date_alternate_second, :datetime_3
  	rename_column :interviews, :selected, :datetime_selected

  	# Interviews Deprecations
  	remove_column :interviews, :school_location
  	remove_column :interviews, :interview_type

  	# Which Interview Is This
  	add_column :interviews, :number, :integer
  	add_column :interviews, :application_id, :integer

  	# Allow Messages Tagging
  	add_column :messages, :tag, :string
  end

  def down
  	remove_column :interviews, :application_id
  	remove_column :interviews, :number

  	add_column :interviews, :school_location, :integer
  	add_column :interviews, :interview_type, :integer

  	remove_column :messages, :tag
  end
end

class AddLongDescriptionToGroups < ActiveRecord::Migration
  def up
  	add_column :groups, :long_description, :text
  end
  def down
  	remove_column :groups, :long_description
  end
end

class AddLatLonToGroups < ActiveRecord::Migration
  def up
  	add_column :groups, :latitude, :float
  	add_column :groups, :longitude, :float
  end

  def down
  	remove_column :groups, :latitude
  	remove_column :groups, :longitude
  end
end

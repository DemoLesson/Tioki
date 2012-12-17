class AddMigratedToSchools < ActiveRecord::Migration
  def up
  	add_column :schools, :migrated, :integer
  end

  def down
  	remove_column :schools, :migrated
  end
end

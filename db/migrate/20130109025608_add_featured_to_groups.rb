class AddFeaturedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :featured, :boolean, :default => false
  end
end

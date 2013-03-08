class AddDataToEduStats < ActiveRecord::Migration
  def change
    add_column :edu_stats, :edu_network_public, :integer
    add_column :edu_stats, :edu_network_private, :integer
    add_column :edu_stats, :edu_network_charter, :integer
    add_column :edu_stats, :edu_network_catholic, :integer
  end
end

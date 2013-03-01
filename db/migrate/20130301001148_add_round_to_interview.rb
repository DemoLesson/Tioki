class AddRoundToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :round, :integer, :default => 1
  end
end

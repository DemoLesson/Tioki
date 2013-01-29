class AddYearsTeachingToUser < ActiveRecord::Migration
  def change
    add_column :users, :years_teaching, :integer
  end
end

class AddTwitterToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :twitter, :string
  end
end

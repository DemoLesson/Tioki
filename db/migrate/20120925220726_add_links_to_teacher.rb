class AddLinksToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :edmodo, :string
    add_column :teachers, :twitter, :string
    add_column :teachers, :betterlesson, :string
  end
end

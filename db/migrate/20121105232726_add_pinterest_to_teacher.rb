class AddPinterestToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :pinterest, :string
  end
end

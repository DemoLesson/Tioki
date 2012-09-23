class Addnulltoteacherurl < ActiveRecord::Migration
  def change
  	change_column :teachers, :url, :string, :null => true
  end
end

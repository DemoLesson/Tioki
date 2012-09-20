class RemoveNullFromTeacherUrl < ActiveRecord::Migration
  def change
  	change_column :teachers, :url, :string, :null => false
  end
end

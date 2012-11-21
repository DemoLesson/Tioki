class TeacherIdCanBeNullOnAnApplication < ActiveRecord::Migration
  def up
  	change_column :applications, :teacher_id, :integer, :null => true
  end

  def down
  	change_column :applications, :teacher_id, :integer, :null => false
  end
end

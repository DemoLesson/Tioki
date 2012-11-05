class AddUrlIndexToTeachers < ActiveRecord::Migration
  def change
		add_index :teachers, :url, :name => 'index_teachers_on_url'
  end
end

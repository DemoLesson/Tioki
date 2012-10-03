class TagSkillsToVideosAndFavorites < ActiveRecord::Migration
	def up
    	create_table :video_favorites, :id => false do |t|
      		t.column :video_id, :integer
      		t.column :teacher_id, :integer
    	end
    	create_table :video_skills, :id => false do |t|
      		t.column :video_id, :integer
      		t.column :skill_id, :integer
    	end
  	end

  	def down
  		drop_table :video_favorites
  		drop_table :video_skills
  	end
end

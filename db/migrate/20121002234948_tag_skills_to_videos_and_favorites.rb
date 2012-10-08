class TagSkillsToVideosAndFavorites < ActiveRecord::Migration
	def up
    	create_table :videos_favorites, :id => false do |t|
      		t.column :video_id, :integer
      		t.column :teacher_id, :integer
    	end
    	create_table :videos_skills, :id => false do |t|
      		t.column :video_id, :integer
      		t.column :skill_id, :integer
    	end
  	end

  	def down
  		drop_table :videos_favorites
  		drop_table :videos_skills
  	end
end

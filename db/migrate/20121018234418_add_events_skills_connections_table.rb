class AddEventsSkillsConnectionsTable < ActiveRecord::Migration
	def up
		create_table :events_skills, :id => false do |t|
			t.integer :event_id
			t.integer :skill_id
			t.timestamps
		end
	end

	def down
		drop_table :events_skills
	end
end

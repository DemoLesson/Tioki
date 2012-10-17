class CreateDiscussionTags < ActiveRecord::Migration
  def change
    create_table :discussion_tags do |t|
      t.integer :skill_id
      t.integer :discussion_id

      t.timestamps
    end

		add_index :discussion_tags, :skill_id
		add_index :discussion_tags, :discussion_id
  end
end

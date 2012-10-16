class CreateDiscussionTags < ActiveRecord::Migration
  def change
    create_table :discussion_tags do |t|
      t.integer :skill_id
      t.integer :discussion_id

      t.timestamps
    end
  end
end

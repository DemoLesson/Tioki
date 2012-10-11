class CreateTechnologyTags < ActiveRecord::Migration
  def change
    create_table :technology_tags do |t|
      t.integer :technology_id
      t.integer :skill_id

      t.timestamps
    end
  end
end

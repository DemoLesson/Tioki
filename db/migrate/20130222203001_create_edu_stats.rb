class CreateEduStats < ActiveRecord::Migration
  def change
    create_table :edu_stats do |t|
      t.integer :user_id
      t.integer :yrs_teaching
      t.integer :avg_class_size
      t.integer :class_perday
      t.integer :total_students
      t.integer :total_hours_teaching
      t.integer :total_hours_planning
      t.integer :total_hours_grading

      t.timestamps
    end
  end
end

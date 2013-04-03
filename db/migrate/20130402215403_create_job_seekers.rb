class CreateJobSeekers < ActiveRecord::Migration
  def change
    create_table :job_seekers do |t|
      t.integer :user_id
      t.string :subject_ids
      t.string :grade_ids
      t.boolean :any_location
      t.string :location
      t.string :box
      t.string :school_type

      t.timestamps
    end
  end
end

class CreateJobQuestions < ActiveRecord::Migration
  def change
    create_table :job_questions do |t|
      t.integer :id
      t.integer :job_id
      t.text :question

      t.timestamps
    end
  end
end

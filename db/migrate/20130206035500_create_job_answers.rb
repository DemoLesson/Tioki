class CreateJobAnswers < ActiveRecord::Migration
  def change
    create_table :job_answers do |t|
      t.integer :id
      t.integer :question_id
      t.integer :application_id
      t.text :answer

      t.timestamps
    end
  end
end

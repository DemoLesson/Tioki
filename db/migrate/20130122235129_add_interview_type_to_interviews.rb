class AddInterviewTypeToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :interview_type, :string
  end
end

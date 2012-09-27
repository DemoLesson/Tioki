class AddTeachingChannelToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :teachingchannel, :string
  end
end

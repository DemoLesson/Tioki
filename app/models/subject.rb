class Subject < ActiveRecord::Base
  attr_accessible :name

  # Join table
  has_and_belongs_to_many :users, :join_table => 'subjects_teachers'
end

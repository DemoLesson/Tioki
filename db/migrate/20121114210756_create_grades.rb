class CreateGrades < ActiveRecord::Migration
  def up

  	# Create the table
  	create_table :grades do |t|
  		t.string :name
  		t.timestamps
  	end

  	# Add the grades to the db
  	Grade.create([
  		{ :name => "Pre-K" },
  		{ :name => "Kindergarden" },
  		{ :name => "1st" },
  		{ :name => "2nd" },
  		{ :name => "3rd" },
  		{ :name => "4th" },
  		{ :name => "5th" },
  		{ :name => "6th" },
  		{ :name => "7th" },
  		{ :name => "8th" },
  		{ :name => "9th" },
  		{ :name => "10th" },
  		{ :name => "11th" },
  		{ :name => "12th" },
  		{ :name => "College Prep" },
  		{ :name => "Undergraduate" },
  		{ :name => "Gradute" },
  		{ :name => "Doctorate" },
  		{ :name => "Post-Doctorate" }
  	])

  	# Index the name
  	add_index :grades, :name

  	# Alter some connection tables by adding some timestamps
  	change_table :jobs_subjects do |t|
    	t.timestamps
  	end

  	change_table :subjects_teachers do |t|
    	t.timestamps
  	end
  end

  def down

  	# Drop the table
  	drop_table :grades
  end
end

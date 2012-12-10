class Teacher < ActiveRecord::Base
	#Without this file the merge_teachers.rake file is broken
	#which is called by the merge_teacher_users migration
	#DON'T DELETE this file until that file is changed to
	#use only sql or the rake task is removed fromt the
	#migration
	
	belongs_to :user
end

class EduStats < ActiveRecord::Base
	belongs_to :user
	validates :yrs_teaching, :numericality => {:only_integer => true}
	validates :avg_class_size, :numericality => {:only_integer => true}
	validates :class_perday, :numericality => {:only_integer => true}
end



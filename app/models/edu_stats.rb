class EduStats < ActiveRecord::Base
	belongs_to :user
	validates :yrs_teaching,
	          :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
	validates :avg_class_size,
	          :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
	validates :class_perday,
	          :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
end



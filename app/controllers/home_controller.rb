class HomeController < ApplicationController
  layout 'standard'
    
  def index
    if self.current_user.nil?
      
    elsif self.current_user.school != nil
      puts "admin user"
      @jobs = Job.find(:all, :conditions => ['school_id = ?', self.current_user.school.id], :order => 'created_at DESC')
    elsif self.current_user.teacher != nil
      @jobs = Job.find(:all, :limit => 4, :order => 'created_at DESC')
    end
  end
  
end

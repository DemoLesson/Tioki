class NotificationsController < ApplicationController
	def index
    @notifications = Discussion.find(:all, :conditions => ["user_id = ?", User.current.id], :order => "created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
	end
end

class CommentsController < ApplicationController
  before_filter :login_required

  def show
    @comment = Comment.find(params[:id])
    render :show, :layout => false
  end
end

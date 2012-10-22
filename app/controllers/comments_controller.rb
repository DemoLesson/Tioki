class CommentsController < ApplicationController
  before_filter :login_required

  def show
    @comment = Comment.find(params[:id])
    render :show, :layout => false
  end

  def favorite

    # Require an authenticated user
    raise HTTPStatus::Unauthorized if User.current.nil?

    w = Comment.find(params[:id])
    fav = Favorite.where("`favorites`.`model` = ? && `favorites`.`user_id` = ?", "#{w.class.name}:#{w.id}", User.current.id).first

    if fav.nil?
      fav = Favorite.new
      fav.model = "#{w.class.name}:#{w.id}"
      fav.user = self.current_user

      # Save the favorite
      if fav.save
        message = {:type => :success, :message => "Comment was successfully favorited.", :new => 1}
      else
        message = {:type => :error, :message => "There was an error favoriting your comment.", :new => 1}
      end
    else
      # Delete the favorite
      if fav.destroy
        message = {:type => :success, :message => "Favorite was successfully deleted.", :new => 0}
      else
        message = {:type => :error, :message => "There was an error deleting your favorite.", :new => 0}
      end
    end

    # Respond with either html or json
    respond_to do |format|
      format.html { flash[message[:type]] = message[:message]; redirect_to :back }
      format.json { render :json => message }
    end
  end

  # Delete a comment from an event
  def delete

    # Require an authenticated user
    raise HTTPStatus::Unauthorized if User.current.nil?

    # Delete the comment and get the proper message
    if Comment.find(params[:id]).destroy
      message = {:type => :success, :message => "Comment was successfully deleted."}
    else
      message = {:type => :error, :message => "There was an error deleting your comment."}
    end

    # Respond with either html or json
    respond_to do |format|
      format.html { flash[message[:type]] = message[:message]; redirect_to :back }
      format.json { render :json => message }
    end
  end
end

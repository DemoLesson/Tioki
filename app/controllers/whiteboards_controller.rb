class WhiteboardsController < ApplicationController
	layout false

	def show
		w = Whiteboard.getActivity.paginate(:per_page => 15, :page => params[:page]).all
		return render :json => w unless params[:raw].nil?

		divs = Array.new
		w.each do |post|
			@post = post
			divs << render_to_string
		end

		render :json => divs
	end

	def favorite
		w = Whiteboard.find(params[:post])
		fav = Favorite.where("`favorites`.`model` = ? && `favorites`.`user_id` = ?", "#{w.class.name}:#{w.id}", User.current.id).first

		if fav.nil?
			fav = Favorite.new
			fav.model = "#{w.class.name}:#{w.id}"
			fav.user = self.current_user

			unless params[:json].nil?
				if fav.save
					return render :json => {'type' => 'success', 'new' => 1}
				else
					return render :json => {'type' => 'error', 'new' => 1}
				end
			else
				if fav.save
					flash[:success] = "The whiteboard posting was been favorited."
					redirect_to :back
				else
					flash[:success] = "The whiteboard could not be favorited."
					redirect_to :back
				end
			end
		else
			unless params[:json].nil?
				if fav.destroy
					return render :json => {'type' => 'success', 'new' => 0}
				else
					return render :json => {'type' => 'error', 'new' => 0}
				end
			else
				if fav.destroy
					flash[:success] = "The whiteboard posting was been unfavorited."
					redirect_to :back
				else
					flash[:success] = "The whiteboard could not be unfavorited."
					redirect_to :back
				end
			end
		end		
	end

	# Add a comment to an event
	def comment

		# Require an authenticated user
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Get the event in question
		whiteboard = Whiteboard.find(params[:id])

		# Create the comment
		comment = whiteboard.createComment(params[:comment])

		# save and get the proper message
		if comment.save
			message = {:type => :success, :message => "Successfully added comment.", :id => comment.id}
		else
			message = {:type => :error, :message => "There was an error posting your comment."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

	def hide

		# Require an authenticated user
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Hide the whiteboard post
		w = Whiteboard.find(params[:post])
		w.whiteboard_hidden << self.current_user

		message = {:type => "success", :message => "Whiteboard post was successfully hidden."}

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

	def delete

		# Require an authenticated user
		raise HTTPStatus::Unauthorized if User.current.nil?

		w = Whiteboard.find(params[:post])

		# Does this post belong to the current user or is the current user an admin
		raise HTTPStatus::Unauthorized if w.user != self.current_user && !self.current_user.is_admin 	

    	# Destroy and get the proper message
		if w.destroy
			message = {:type => :success, :message => "Successfully deleted whiteboard post.", :id => comment.id}
		else
			message = {:type => :error, :message => "There was an error deleting the whiteboard post."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

end
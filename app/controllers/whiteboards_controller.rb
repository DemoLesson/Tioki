class WhiteboardsController < ApplicationController
	layout false

	def show
		w = Whiteboard.getActivity(true, :exclude => :connection).paginate(:per_page => 15, :page => params[:page]).all
		return render :json => w unless params[:raw].nil?

		divs = Array.new
		w.each do |post|
			@post = post
			divs << render_to_string
		end

		render :json => divs
	end

	def favorite

		# Require an authenticated user
		raise HTTPStatus::Unauthorized if User.current.nil?

		w = Whiteboard.find(params[:post])
		fav = Favorite.where("`favorites`.`model` = ? && `favorites`.`user_id` = ?", "#{w.class.name}:#{w.id}", User.current.id).first

		if fav.nil?
			fav = Favorite.new
			fav.model = "#{w.class.name}:#{w.id}"
			fav.user = self.current_user

			# Save the favorite
			if fav.save
				message = {:type => :success, :message => "Whiteboard post was successfully favorited.", :new => 1}
				Notification.create(:user_id => w.user_id, :notifiable_type => fav.tag!, :message => "{triggered.link} favorited a post of yours.", :link => '', :bucket => :favorites)
				self.log_analytic(:post_favorited, "Whiteboard post favorited", fav, [], :whiteboard)
			else
				message = {:type => :error, :message => "There was an error favoriting the specified post.", :new => 1}
			end
		else
			# Delete the favorite
			if fav.destroy
				message = {:type => :success, :message => "Whiteboard post was successfully favorited.", :new => 0}
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

	# Add a comment to a post
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
			self.log_analytic(:whiteboard_comment, "User commented on whiteboard post", comment, [], :whiteboard)
			if self.current_user.id != whiteboard.user_id
				Notification.create(:notifiable_type => comment.tag!, :user_id => whiteboard.user_id, :message => "{triggered.link} commented on a item you shared.", :link => '', :bucket => :discussions)
				# email_permissions
				if !whiteboard.user.email_permissions["whiteboard_post"]
					NotificationMailer.comment(whiteboard.user, comment, whiteboard).deliver
				end
			end
		else
			message = {:type => :error, :message => "There was an error posting your comment."}
		end

		#Put email here

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
			message = {:type => :success, :message => "Successfully deleted whiteboard post."}
		else
			message = {:type => :error, :message => "There was an error deleting the whiteboard post."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

	def user_profile

		# Find the user in question
		@user = User.find(params[:user_id])

		# Set the user profile page
		page = params[:page].nil? || params[:page].empty? ? 1 : params[:page]

		# Get the users whiteboard activity
		w = Whiteboard.where(:user_id => @user.id).order('created_at DESC').paginate(:per_page => 15, :page => page)

		# Render the result as JSON unless raw is requested
		return render :json => w unless params[:raw].nil?

		divs = Array.new
		w.each do |post|
			@post = post
			divs << render_to_string('whiteboards/profile_whiteboard', :layout => false)
		end

		render :json => divs
	end

end

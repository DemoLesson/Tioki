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

	def hide
		w = Whiteboard.find(params[:post])
		w.whiteboard_hidden << self.current_user
    	return redirect_to :back if params[:json].nil?
    	return render :json => {'type' => 'success'}
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

	def delete
		w = Whiteboard.find(params[:post])
    	return redirect_to :back if (self.current_user.nil? || (w.user != self.current_user && !self.current_user.is_admin)) && params[:json].nil?

    	# Destroy
    	w.destroy

    	return redirect_to :back if params[:json].nil?
    	return render :json => {'type' => 'success'}
	end

end
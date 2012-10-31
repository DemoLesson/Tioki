class GroupsController < ApplicationController

	def index
		@groups = Group.permissions(:slugs => {:public => 1, :private => 1}, :type => 'OR')
	end

	def show

		# Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		@admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin

		# Is the current user in a group
		unless self.current_user.nil?
			@in_group = self.current_user.groups.include?(@group)
		else
			@in_group = false
		end
	end

	def edit

		# If the user is not logged in the user is unauthorized
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		raise HTTPStatus::Unauthorized unless admin
	end

	def update

		# If the user is not logged in the user is unauthorized
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		raise HTTPStatus::Unauthorized unless admin

		@group.update_attributes(params[:group])

		redirect_to group
	end
end
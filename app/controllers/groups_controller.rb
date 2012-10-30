class GroupsController < ApplicationController

	def index
		@groups = Group.permissions(:slugs => {:public => 1, :private => 1}, :type => 'OR').to_sql
		dump @groups
	end

	def show
		@group = Group.find(params[:id])
	end
end
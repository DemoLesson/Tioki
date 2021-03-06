class ApiController < ApplicationController
  class BlockJson < StandardError; end

	# Load in api methods
	files = Dir.glob File.dirname(__FILE__) + "/api/*.{rb}"
	files.each { |f| load f }

	def method_missing(collection, *args)

		# Get the method to run
		method = '_' + collection.to_s

		# Get params and cut out actions and controller
		_params = params.clone
		_params.delete_if{|k,v| k == 'action' || k == 'controller' }

		# Append new params to the args
		args.push(_params)

		begin
			if params[:id].nil?
				# If no id just run the method
				r = send(method, *args) 
			else
				# Prepend the id to the args and run method
				args.unshift(params[:id])
				r = send(method + '_id', *args)
			end

			# Render the returned result as json
			render :json => r
		rescue BlockJson => e
		end
	end

	def __rank(type = false)
		raise SecurityTransgression if User.current.nil? || !User.current.rank?
	end
end
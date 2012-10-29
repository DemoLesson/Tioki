class BlockJson < StandardError
end

class ApiController < ApplicationController
	load 'api/users.rb'

	def method_missing(collection, *args)

		# Get the method to run
		method = '_' + collection.to_s

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
		raise HTTPStatus::Unauthorized if User.current.nil? || !User.current.rank?
	end
end
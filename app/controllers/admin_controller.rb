class AdminController < ApplicationController
	around_filter :check_for_admin
	layout 'admin'

	private

		def check_for_admin
			if currentUser.is_admin
				yield
			else
				raise SecurityTransgression
			end
		end

end
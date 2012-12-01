class TeachersController < ApplicationController
	before_filter :login_required, :except => [:profile, :guest_entry]


	


	
end

Preview::Application.routes.draw do

	# Match API urls
	scope '/api' do
		match ':action/:id' => 'api#:action'
		match ':action' => 'api#:action'
	end

	#Authentication for twitter, facebook, linkedin etc.
	resources :authentications do
		collection do
			get 'facebook_auth'
			get 'whiteboard_share_twitter'
			get 'whiteboard_share_facebook'
			get 'revoke_twitter'
			get 'revoke_facebook'
		end
	end
	match 'facebook_callback', :to => 'authentications#facebook_callback'
	match 'twitter_callback', :to => 'authentications#twitter_callback' 
	match 'twitter_auth', :to => 'authentications#twitter_auth'
	match 'linkedinprofile', :to => 'teachers#linkedinprofile'
	match 'linkedin_callback', :to => 'authentications#linkedin_callback'

	# Groups
	match 'groups/:id/comment' => 'groups#comment'
	match 'my_groups' => 'groups#my_groups'
	match 'groups/:id/members' => 'groups#members'
	match 'groups/:id/about' => 'groups#about'
	match 'groups/:id/inviting' => 'groups#inviting'
	match ':id/invite_email' => 'groups#invite_email'
	match 'groups/:id/invite' => 'groups#invite'
	resources :groups do
		member do
			get 'edit_picture'
			get 'add_group'
			get 'message_all_new'
			post 'message_all_create'
		end
	end

	# Match Comment URLS
	match 'comments/:id/favorite' => 'comments#favorite'
	match 'comments/:id/delete' => 'comments#delete'
	resources :comments

	# Match Discussions
	resources :discussions do
		member do
			get 'reply_to_discussion'
			post 'reply_to_discussion'
			get 'reply_to_comment'
			post 'reply_to_comment'
			get 'follow_discussion'
			get 'unfollow_discussion'
			get 'destroy_discussion'
			get 'restore_discussion'
			post 'reply_nologin'
		end
	end
	match 'followed_discussions' => 'discussions#followed_discussions'
	match 'my_discussions' => 'discussions#my_discussions'
	match 'destroy_comment/:id' => 'discussions#destroy_comment'
	match 'edit_comment/:id' => 'discussions#edit_comment'
	match 'update_comment/:id' => 'discussions#update_comment'
	match 'discussions/:id/invite' => 'discussions#invite'

	# Match Technologies
	match 'technologies/:id/comment' => 'technologies#comment'
	resources :technologies do
		member do
			get 'change_technology_picture'
			get 'edit_technology_tags'
			post 'edit_technology_tags'
			get 'add_technology'
			get 'remove_technology'
			get 'skills'
		end
	end

	# Match S3 Uploads
	resources :s3_uploads

	# Get the connections distance
	match 'distance/:id' => 'connections#distance'

	#Warning: make sure user URL can't be set to any of these

	# Events routing
	match 'events/:id/comment' => 'events#comment'
	resources :events do
		collection do
			get 'list'
			get 'invite'
		end
	end

	# Cron Jobs
	resources :cron

	# Metrics Controller
	resources :metrics

	# Analytics Controller
	match 'analytics/slugs' => 'analytics#slugs'
	match 'analytics/users' => 'analytics#users'
	match 'analytics/user/:id' => 'analytics#user'
	match 'analytics/slug/:slug' => 'analytics#slug'
	resources :analytics

	# Welcome Wizard Controller
	resources :welcome_wizard

	# Whiteboard JSON Access
	resource :whiteboard
	match 'whiteboard/hide/:post' => 'whiteboards#hide'
	match 'whiteboard/delete/:post' => 'whiteboards#delete'
	match 'whiteboard/:id/comment' => 'whiteboards#comment'
	match 'whiteboard/favorite/:post' => 'whiteboards#favorite'

	# Signup / Login
	match 'signup' => 'users#signup'
	match 'login' => 'users#login'

	# Home page
	match 'index' => "home#index"

	# Anything involving me
	scope 'me' do

		# Anything involving my profile
		scope 'profile' do

			# Anything involving editing my profile
			scope 'edit' do
				match 'skills' => 'teachers#edit_skills'
				match 'experience' => 'teachers#experience'
				match 'education' => 'teachers#education'
				match 'upload-avatar' => 'users#change_picture'
				match 'upload-video' => 'videos#new'
				match 'create-video-snippet/:id' => 'videos#myvideo'
				match 'feature-video/:id' => 'teachers#feature_video'
				resources :credentials
				root :to => 'teachers#edit'
				resources :awards
				resources :presentations
				resources :awards
			end

			# Misc
			match 'stats' => 'teachers#stats'
			match 'card' => 'card#get'
			root :to => 'teachers#profile'
		end

		scope 'settings' do
			match 'privacy' => 'users#privacy'
			root :to => 'users#edit'
		end

		# User dashboard
		root :to => 'home#index'
	end

	# Profile Views
	scope 'profile' do

		# Videos
		match ':url/videos' => 'videos#index'
		match ':url/videos/:id' => 'videos#show'

		# Card Profile
		match ':url/card' => 'card#get'

		# Guest Access
		match ':url/:guest_pass' => 'teachers#profile'
		# Normal Access
		match ':url' => 'teachers#profile'
	end

	# Handle guest passcodes
	match 'guest/:guest_pass' => 'teachers#guest_entry'

	# Static pages by default route the action
	# Sub folders a bit trickier
	scope '/static' do
		match ':action' => 'static#:action'
		match 'resources/:page' => 'static#_resources'
	end

	# Event action routing
	scope 'events' do
		match ':id/invite' => 'events#invite'
		match ':id/invite_email' => 'events#invite_email'
		match ':id/rsvp' => 'events#rsvp'
	end

	# Admin Routing
	scope 'admin' do
		scope 'users' do
			match 'create_teacher' => 'users#create_teacher_and_redirect'
		end
		match 'banners' => 'users#banners'
		match 'banners/delete/:id' => 'users#delete_banner'
		match 'videos' => 'videos#admin'
	end

	# Videos Routing
	match 'videos/:id/skills' => 'videos#skills'

	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	
	#Actions
	match 'create', :to => 'users#create'
	match 'login', :to => 'users#login', :as => 'login'
	match 'jlogin' => 'users#login_json'
	match 'jregister' => 'users#create_json'
	match 'logout', :to => 'users#logout', :as => 'logout'
	match 'verify', :to => 'users#verify', :as => 'verify'
	match 'forgot_password', :to => 'users#forgot_password', :as => 'forgot_password'
	match 'change_password', :to => 'users#change_password', :as => 'change_password'  
	match 'update_settings' => 'users#update_settings'
	match 'email_settings' => 'users#email_settings'
	match 'change_org_info' => 'users#change_org_info'
	#match 'choose_stored', :to => 'users#choose_stored', :as => 'choose_stored'
	match 'change_picture', :to => 'users#change_picture'
	match 'create_profile', :to => 'teachers#create_profile'
	match 'change_school_picture/:id', :to => 'schools#change_school_picture'
	match 'skills', :to => 'skills#get'
	match 'crop', :to => 'users#crop'
	match 'crop_image', :to => 'users#crop_image'
	match 'crop_image_temp', :to => 'users#crop_image_temp'
	match 'crop_temp', :to => 'users#crop_temp'
	
	# Beta
	root :to => "home#index"
	match 'beta_teacher' => "alphas#teacher"
	match 'beta_admin' => "alphas#admin"
	match 'beta_general' => "alphas#general"
	
	# Account/Teacher
	match 'account/:id' => 'users#edit'
	match 'add_pin' => 'teachers#add_pin'
	match 'remove_pin' => 'teachers#remove_pin'
	match 'add_star' => 'teachers#add_star'
	match 'remove_star' => 'teachers#remove_star'
	match 'add_connection' => 'connections#add_connection'
	match 'remove_connection' => 'connections#remove_connection'
	match 'accept_connection' => 'connections#accept_connection'
	match 'remove_pending' => 'connections#remove_pending'
	match 'show_my_connections' => 'connections#show_my_connections'
	match 'newconnections' => 'connections#new_connections'
	match 'purge/:id' => 'teachers#purge'
	match 'users' => 'users#update'
	match 'attach' => 'teachers#attach'
	match 'teachers/:id/skills' => 'teachers#skills'
	match 'skillpage' => 'skills#skillpage'
	match 'jobattach' => 'jobs#attach'
	match 'videos/record' => 'videos#record'
	match 'videos/create_snippet' => 'videos#create_snippet'
	match 'teacher_applications' =>'teachers#teacher_applications'
	match 'appattachments/:id' =>  'teachers#appattachments'
	match 'my_connections' => 'connections#my_connections'
	match 'pending_connections' => 'connections#pending_connections'
	match 'userconnections/:id' => 'connections#userconnections'
	match 'myvideo' => 'videos#myvideo'
	match 'inviteconnections' => 'connections#inviteconnections' 
	match 'inviteconnection' => 'connections#inviteconnection'
	match 'education', :to => 'teachers#education'
	match 'update_education' => 'teachers#update_education'
	match 'remove_education/:id' => 'teachers#remove_education'
	match 'edit_education/:id' => 'teachers#edit_education'
	match 'update_existing_education/:id' => 'teachers#update_existing_education'
	match 'teacherskills/:id' => 'skills#teacherskills'
	match 'add_embed' => 'videos#add_embed'
  match 'profileattachments' => 'teachers#profileattachments'
	match 'dc/:url' => 'connections#linkinvite'
	match 'ww/:url' => 'connections#welcome_wizard_invite'
	match 'techsuggestion' => 'technologies#techsuggestion'
	match 'sendtechsuggestion' => 'technologies#sendtechsuggestion'
	match 'tioki_bucks' => 'teachers#tioki_bucks'
	match 'get_started' => 'teachers#get_started'
	
	match 'experience', :to => 'teachers#experience'
	match 'update_experience' => 'teachers#update_experience'
	match 'remove_experience/:id' => 'teachers#remove_experience'
	match 'edit_experience/:id' => 'teachers#edit_experience'
	match 'update_existing_experience/:id' => 'teachers#update_existing_experience'
  
	get "home/index"
	match 'share_on_whiteboard' => 'home#whiteboard_share'
	match 'delete_from_whiteboard' => 'home#whiteboard_rmv'
	match 'hide_from_whiteboard' => 'whiteboards#hide'
	match 'apply/:id' => 'jobs#apply'
	match 'kipp_apply/:id' => 'jobs#kipp_apply'
	match 'tfa_apply/:id' => 'jobs#tfa_apply'
	match 'apply_confirmation/:id' => 'jobs#apply_confirmation'
	match 'apply_confirmation' => 'jobs#apply_confirmation'
	match 'job_referral/:id' => 'jobs#job_referral'
	match 'job_referral' => 'jobs#job_referral'
	match 'job_referral_email/:id' => 'jobs#job_referral_email'
	match 'site_referral/:id' => 'home#site_referral'
	match 'site_referral' => 'home#site_referral'
	match 'site_referral_email' => 'home#site_referral_email'
	match 'school_signup' => 'home#school_signup'
	match 'create_admin' => 'users#create_admin'
	match 'my_jobs' => 'jobs#my_jobs'
	match 'forschools' => 'home#school_splash'
	match 'my_jobs/:school_id' => 'jobs#my_jobs'
	match 'my_schools' => 'schools#my_schools'
	match 'add_school' => 'schools#add_school'
	match 'applications/:id' => 'applications#index'
	match 'applications/reject/:id' => 'applications#reject'
	match 'applications/attachments/:id' => 'applications#attachments'
	match 'about' => 'home#about'
	match 'blog' => 'blog_entries#index'
	match 'privacy' => 'home#privacy'
	match 'termsofservice' => 'home#terms_of_service'
	match 'howitworks' => 'home#how_it_works_teachers'
	match 'howitworks/schools' => 'home#how_it_works_schools'
	match 'contact' => 'home#contact'
	match 'my_interviews' => 'interviews#my_interviews'
	match 'teachersignup' => 'alphas#beta'
	match 'resources' => 'home#resources'
	match 'customers' => 'home#customers'
	match 'press' => 'home#press'
	match 'school_thankyou' => 'home#school_thankyou'
	match 'dmca' => 'home#dmca'
	
	# Admin
	match 'admin' => 'users#teacher_user_list'
	match 'teachlist' => 'users#teacher_user_list'
	match 'schoollist' => 'users#school_user_list'
	match 'deactivatedlist' => 'users#deactivated_user_list'
	match 'pendingevents' => 'events#admin_events'
	match 'organizationlist' => 'users#organization_user_list'
	match 'referrallist' => 'users#referral_user_list'
	match 'donorschoose' => 'users#donors_choose_list'
	match 'technologylist' => 'technologies#technology_list'
	match 'tiokicoinslist' => 'users#tioki_coins_list'
	match 'blogadmin' => 'blog_entries#list'
	match 'fetch_code' => 'users#fetch_code'
	match 'jobattachpurge/:id' => 'jobs#jobattachpurge'
	
	match 'interviews/new' => 'interviews#new'
	match 'interviews/respond' => 'interviews#respond'
	resources :interviews
	match 'interviews/:id' => 'interviews#show'
	match 'messages/sent' => 'messages#sent'
	match 'new_member' => 'users#new_member'
	match 'edit_member/:id' => 'users#edit_member'
	match 'accounts/:id' => 'users#accounts'
	match 'manage/:id' => 'users#manage'
	match 'favorites' => 'teachers#favorites'
	match 'jobs/:id/jobattachments' => 'jobs#jobattachpost'
	match '/postattach' => 'jobs#jobattachpost'
	
	match 'teachers_faq' => 'home#teachers_faq'
	match 'schools_faq' => 'home#schools_faq'
	match 'update_details' => 'video#update_details'


	#Card
	match 'card'      => 'card#get'
	match 'card/:url' => 'card#get'
	match 'cardeducation' => 'card#addEducation'
	match 'cardexperience' => 'card#addExperience'
	match 'cardcredential' => 'card#addCredential'
	match 'cardskills' => 'card#addSkills'
	match 'cardremoveskills' => 'card#removeSkills'
	match 'cardheadline' => 'card#cardheadline'
	match 'cardavatar' => 'card#cardavatar'
	match 'change_location' => 'card#change_location'

	#Vouches
	match 'vouchrequest' => 'vouches#vouchrequest'
	match 'vouchresponse' => 'vouches#vouchresponse'
	match 'updatevouch' => 'vouches#updatevouch'
	match 'requestvouch' => 'teachers#request_vouch'
	match 'unlocked' => 'vouches#unlocked'
	match 'addvouch' => 'vouches#addvouch'

	#resources :jobs do 
	#  get :auto_complete_search, :on => :collection
	#end
	
	resources :alphas
	resources :winks
	resources :reviews
	resources :jobs
	resources :applications
	resources :review_permissions
	resources :schools
	resources :teachers
	resources :videos
	resources :users
	resources :blogentries
	resources :organizations

	resources :pins
	resources :subjects
	resources :blog_entries
	resources :messages
	resources :vouches
	resources :connections do
		collection do
			get 'add_and_redir'
		end
	end

	resources :skills
	
	# pitches
	match '/techstars' => 'home#video1'
	match '/techstarsteam' => 'home#video2'
	match '/upstartla' => 'home#video3'
	match '/harvardbiz' => 'home#video4'
	match '/demolesson' => 'home#how_it_works_teachers'
	match '/muckerlab' => 'home#muckerlab'

	# # # # # # # # # # # # # # # # # # # # # #
	# Guest pass                              #
	# Removed by KellyLSB 10-03-2012 10:36am  #
	# # # # # # # # # # # # # # # # # # # # # #
	# match 'u/:guest_pass' => 'teachers#guest_entry'
	# match '/:url/:guest_pass', :to => 'teachers#profile'
	# match '/:url', :to => 'teachers#profile'

	# # # # # # # 
	# Error 404 #
	# # # # # # #
	match '*not_found' => 'errors#error_404'
	
	# The priority is based upon order of creation:
	# first created -> highest priority.

	# Sample of regular route:
	#   match 'products/:id' => 'catalog#view'
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
	# This route can be invoked with purchase_url(:id => product.id)

	# Sample resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Sample resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Sample resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Sample resource route with more complex sub-resources
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', :on => :collection
	#     end
	#   end

	# Sample resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

	# You can have the root of your site routed with "root"
	# just remember to delete public/index.html.
	# root :to => 'welcome#index'

	# See how all your routes lay out with "rake routes"

	# This is a legacy wild controller route that's not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	# match ':controller(/:action(/:id(.:format)))'
end

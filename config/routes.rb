Preview::Application.routes.draw do
	ActiveAdmin.routes(self)
	devise_for :users, ActiveAdmin::Devise.config

	resources :applications

	match '/temp' => 'users#temp'

	# API
		scope '/api' do
			match ':action/:id' => 'api#:action'
			match ':action' => 'api#:action'
		end

	# Authentication for twitter, facebook, linkedin etc.
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
		match 'linkedinprofile', :to => 'users#linkedinprofile'
		match 'linkedin_callback', :to => 'authentications#linkedin_callback'

	# Groups

		match 'groups/:id/comment' => 'groups#comment'
		match 'groups/:id/add_admin/:user' => 'groups#add_admin'
		match 'groups/:id/rmv_admin/:user' => 'groups#rmv_admin'
		match 'groups/:id/inviting' => 'groups#inviting'
		match ':id/invite_email' => 'groups#invite_email'
		match 'groups/:id/invite' => 'groups#invite'

		match 'groups/:id/members' => 'groups#members'
		match 'groups/:id/discussions' => 'groups#discussions'

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
		match 'discussions/:id/inviting' => 'discussions#inviting'
		match ':id/discussion_email' => 'discussions#discussion_email'

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

	# Warning: make sure user URL can't be set to any of these

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

	# Jobs
		resources :jobs do
			collection do
				get 'preferences'
				post 'preferences'
			end
		end


	# Analytics Controller
		match 'analytics/slugs' => 'analytics#slugs'
		match 'analytics/users' => 'analytics#users'
		match 'analytics/user/:id' => 'analytics#user'
		match 'analytics/slug/:slug' => 'analytics#slug'
		resources :analytics

	# Welcome Wizard Controller
	# @todo Deprecate to new format
		resources :welcome_wizard

		scope '/wizards' do
			match 'welcome' => 'welcome_wizard#index'
			match 'welcome/:action' => 'welcome_wizard#:action'

			match 'application/:action' => 'application_wizard#:action'
			match 'application' => 'application_wizard#index'
		end

	# Edu Stats Controller
		resources :edu_stats

		match 'edu_stats' => 'edu_stats#index'
		match 'edu_stats/results' => 'edu_stats#show'

	# Whiteboard JSON Access
	# Move to API
		resource :whiteboard
		match 'whiteboard/hide/:post' => 'whiteboards#hide'
		match 'whiteboard/delete/:post' => 'whiteboards#delete'
		match 'whiteboard/:id/comment' => 'whiteboards#comment'
		match 'whiteboard/favorite/:post' => 'whiteboards#favorite'
		match 'whiteboard/user_profile' => 'whiteboards#user_profile'
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
				resources :educations
				resources :experiences
				resources :credentials
				resources :awards
				resources :presentations
				resources :attachments

				match 'skills/my_skills', :to => 'skills#my_skills'
				resources :skills
				
				match 'upload-avatar' => 'users#change_picture'
				match 'upload-video' => 'videos#new'
				match 'create-video-snippet/:id' => 'videos#myvideo'
				match 'slug_availability' => 'users#slug_availability'
				match 'feature-video/:id' => 'videos#feature_video'
				
				root :to => 'users#profile_edit'
				match 'complete' => 'users#profile_complete'
			end

			#profile Views
			match 'resume' => 'users#profile_resume'
			match 'about' => 'users#profile_about'
			match 'application' => 'users#profile_application'

			# Misc
			match 'stats' => 'users#profile_stats'
			root :to => 'users#profile'
		end


		# My settings
		scope 'settings' do
			match 'upgrade' => 'users#upgrade'
			match 'dashboard/:switch' => 'users#swap_dashboard'
			match 'privacy' => 'users#privacy'
			root :to => 'users#edit'
		end

		# Dismiss the banner
		match 'dismiss_banner' => 'users#dismiss_banner'

		# User dashboard
		root :to => 'home#index'
	end

	# Profile Views
	scope 'profile' do

		# Videos
		match ':slug/videos' => 'videos#index'
		match ':slug/videos/:id' => 'videos#show'

		# Connections
		match ':slug/connections' => 'connections#profile_connections'
		
		# About 
		match ':slug/about' => 'users#profile_about'

		match ':slug/application' => 'users#profile_application'
		
		# Resume Info
		match ':slug/resume' => 'users#profile_resume'

		# Skills
		match ':slug/skills' => 'skills#my_skills'

		match ':slug/more_groups' => 'users#more_groups'

		match ':slug/more_tech' => 'users#more_tech'

		# Guest Access
		match ':slug/:guest_pass' => 'users#profile'
		
		# Normal Access
		match ':slug' => 'users#profile'

	end

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
		end
		match 'banners' => 'users#banners'
		match 'banners/delete/:id' => 'users#delete_banner'
		match 'videos' => 'videos#admin'
	end

	# Connections
	resources :connections do
		collection do
			get 'add_and_redir'
		end
	end
	match '/connections/user/:id' => 'connections#profile_connections'

	# Videos Routing
	match '/videos/:id/skills' => 'videos#skills'

	# Skills information page
	match '/skill/:id' => 'skills#show'

	# Users routes
	resources :users do

		resources :jobs
		resources :groups

		# User Applications
		resources :applications do

			# Interviews
			resources :interviews
		end
	end

	# Groups
	resources :groups do

		# Job pack purchases
		resources :job_packs

		# Jobs routes
		resources :jobs do
			collection do
				get 'request_credits'
				post 'credit_request_email'
			end

			# Job Applications
			resources :applications do
				get 'message', :on => :member
				collection do
					get 'reviewed_applicants'
					get 'interviews'
					get 'declined'
					get 'offered'
					get 'accepted'
					get 'hired'
				end
				# Interviews
				resources :interviews
			end
		end
	end

	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	# # # # # # # # # # # # # #
	
	#Actions
	match 'create', :to => 'users#create'
	match 'login', :to => 'users#login', :as => 'login'
	match 'logout', :to => 'users#logout', :as => 'logout'
	match 'verify', :to => 'users#verify', :as => 'verify'
	match 'forgot_password', :to => 'users#forgot_password', :as => 'forgot_password'
	match 'change_password', :to => 'users#change_password', :as => 'change_password'  
	match 'update_settings' => 'users#update_settings'
	match 'email_settings' => 'users#email_settings'
	match 'change_org_info' => 'users#change_org_info'
	match 'change_picture', :to => 'users#change_picture'
	
	match 'change_school_picture/:id', :to => 'schools#change_school_picture'
	match 'crop', :to => 'users#crop'
	match 'crop_image', :to => 'users#crop_image'
	match 'crop_image_temp', :to => 'users#crop_image_temp'
	match 'crop_temp', :to => 'users#crop_temp'
	
	# Account/Teacher
	match 'account/:id' => 'users#edit'
	match 'add_connection' => 'connections#add_connection'
	match 'remove_connection' => 'connections#remove_connection'
	match 'accept_connection' => 'connections#accept_connection'
	match 'remove_pending' => 'connections#remove_pending'
	match 'show_my_connections' => 'connections#show_my_connections'
	match 'newconnections' => 'connections#new_connections'
	match 'purge/:id' => 'attachments#purge'
	match 'users' => 'users#update'
	match 'attach' => 'attachments#attach'
	match 'skillpage' => 'skills#skillpage'
	match 'jobattach' => 'jobs#attach'
	match 'videos/record' => 'videos#record'
	match 'videos/create_snippet' => 'videos#create_snippet'
	match 'teacher_applications' =>'applications#teacher_applications'
	match 'appattachments/:id' =>  'applications#appattachments'
	match 'my_connections' => 'connections#my_connections'
	match 'pending_connections' => 'connections#pending_connections'
	match 'myvideo' => 'videos#myvideo'
	match 'inviteconnections' => 'connections#inviteconnections' 
	match 'inviteconnection' => 'connections#inviteconnection'
	match 'inviteconnections/facebook' => 'connections#invite_facebook'
	match 'inviteconnections/twitter' => 'connections#invite_twitter'
	match 'inviteconnections/gmail' => 'connections#invite_gmail'
	match 'inviteconnections/yahoo' => 'connections#invite_yahoo'
	match 'add_embed' => 'videos#add_embed'
	match 'profileattachments' => 'attachments#profileattachments'
	match 'techsuggestion' => 'technologies#techsuggestion'
	match 'sendtechsuggestion' => 'technologies#sendtechsuggestion'
	match 'tioki_bucks' => 'users#tioki_bucks'
	match 'get_started' => 'users#get_started'

	#Invite connection
	match 'dc/:url' => 'connections#linkinvite'
	match 'ww/:url' => 'connections#welcome_wizard_invite'
	match 'tw/:url' => 'connections#invite_from_twitter'
	match 'fb/:url' => 'connections#invite_from_facebook'
  
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
	match 'my_jobs' => 'jobs#my_jobs'
	match 'forschools' => 'home#school_splash'
	match 'schoolpricing' => 'home#school_pricing'
	match 'my_jobs/:school_id' => 'jobs#my_jobs'
	match 'my_schools' => 'schools#my_schools'
	match 'add_school' => 'schools#add_school'
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
	match 'deactivatedlist' => 'users#deactivated_user_list'
	match 'pendingevents' => 'events#admin_events'
	match 'organizationlist' => 'users#organization_user_list'
	match 'active_job_list' => 'users#active_job_list'
	match 'geography' => 'users#geography'
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
	match 'jobs/:id/jobattachments' => 'jobs#jobattachpost'
	match '/postattach' => 'jobs#jobattachpost'
	
	match 'teachers_faq' => 'home#teachers_faq'
	match 'schools_faq' => 'home#schools_faq'
	match 'update_details' => 'video#update_details'

	#Vouches
	match 'vouchrequest' => 'vouches#vouchrequest'
	match 'vouchresponse' => 'vouches#vouchresponse'
	match 'updatevouch' => 'vouches#updatevouch'
	match 'requestvouch' => 'vouches#request_vouch'
	match 'addvouch' => 'vouches#addvouch'
	match 'vouch_connection_skills' => 'vouches#vouch_connection_skills'

	resources :reviews
	resources :review_permissions
	resources :schools
	resources :videos
	resources :organizations
	resources :attachments
	resources :subjects
	resources :messages
	resources :vouches
	resources :assets
	

	resources :skills
	
	# # # # # # #
	# Site Home #
	# # # # # # #
	root :to => 'home#index'
	match '/index', :to => 'home#index'

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

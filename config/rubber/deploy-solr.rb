namespace :rubber do
	namespace :solr do

		rubber.allow_optional_tasks(self)

		after "rubber:install_gems", "rubber:solr:install"

		task :install, :roles => :solr do
			rsudo "sunspot-installer"
		end

		before "deploy:stop", "rubber:solr:stop"
		after "deploy:start", "rubber:solr:start"
		after "deploy:restart", "rubber:solr:reload"

		desc "Stops the solr server"
		task :stop, :roles => :solr do
			rsudo "if [ -f /var/run/sunspot-solr.pid ]; then cd #{current_path} && RAILS_ENV=#{Rubber.env} sunspot-solr --pid=dir=/var/run stop; fi"
		end

		desc "Starts the solr server"
		task :start, :roles => :solr do
			rsudo "cd #{current_path} && RAILS_ENV=#{Rubber.env} sunspot-solr --pid=dir=/var/run start"
		end

		desc "Restarts the solr server"
		task :restart, :roles => :solr do
			stop
			start
		end

		desc "Reloads the solr web server"
		task :reload, :roles => :solr do
			restart
		end
	end
end

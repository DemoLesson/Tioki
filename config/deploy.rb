# Load the delayed job recipies
require "delayed/recipes"

# Set the rails environment
set :rails_env, Rubber.env

# Set the generic config info
on :load do
  set :application, rubber_env.app_name                         # Application name
  set :runner,      rubber_env.app_user                         # User under which this application runs
  set :deploy_to,   "/mnt/#{application}-#{Rubber.env}"         # Folder on server where the application runs from
  set :copy_exclude, [".git/*", ".bundle/*", "log/*", ".rvmrc"] # What files should we ignore
end

# Start by using Git checkout
set :scm, :git
set :scm_verbose, true
set :repository, "https://bde517dd911d0961403d72a933bf2e989310892c:x-oauth-basic@github.com/DemoLesson/Tioki"

# In production deploy only master otherwise use the current branch
set :branch, "master" if Rubber.env == 'production'
set :branch, `git symbolic-ref --short -q HEAD`.strip if Rubber.env != 'production'
set :git_shallow_clone, 1
set :deploy_via, :export

# Run system level server configuration as root (no pass rqd)
set :user, 'root'
set :password, nil

# Run deploy using sudo (where possible)
set :use_sudo, true

# Keep 3 releases to rollback too
set :keep_releases, 3

# Lets us work with staging instances without having to checkin config files
# (instance*.yml + rubber*.yml) for a deploy.  This gives us the
# convenience of not having to checkin files for staging, as well as 
# the safety of forcing it to be checked in for production.
set :push_instance_config, Rubber.env != 'production'

# don't waste time bundling gems that don't need to be there 
set :bundle_without, [:development, :test, :staging] if Rubber.env == 'production'

# Allow us to do N hosts at a time for all tasks - useful when trying
# to figure out which host in a large set is down:
# RUBBER_ENV=production MAX_HOSTS=1 cap invoke COMMAND=hostname
max_hosts = ENV['MAX_HOSTS'].to_i
default_run_options[:max_hosts] = max_hosts if max_hosts > 0

# Allows the tasks defined to fail gracefully if there are no hosts for them.
# Comment out or use "required_task" for default cap behavior of a hard failure
rubber.allow_optional_tasks(self)

# Wrap tasks in the deploy namespace that have roles so that we can use FILTER
# with something like a deploy:cold which tries to run deploy:migrate but can't
# because we filtered out the :db role
namespace :deploy do
  rubber.allow_optional_tasks(self)
  tasks.values.each do |t|
    if t.options[:roles]
      task t.name, t.options, &t.body
    end
  end
end

namespace :deploy do
  namespace :assets do
    rubber.allow_optional_tasks(self)
    tasks.values.each do |t|
      if t.options[:roles]
        task t.name, t.options, &t.body
      end
    end
  end
end

# load in the deploy scripts installed by vulcanize for each rubber module
Dir["#{File.dirname(__FILE__)}/rubber/deploy-*.rb"].each do |deploy_file|
  load deploy_file
end

# Start websockets / delayed job daemons
after "deploy:restart", "websockets:start"
after "deploy:restart", "delayed_job:start"

# Add chmod to after rubber:setup_app_permissions
after "rubber:setup_app_permissions", "deploy:chmod:all"

# Reconfigure rubber on rollback
after "deploy:rollback:revision", "rubber:config:current"
after "deploy:rollback:revision", "deploy:assets:current"
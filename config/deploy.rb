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

# Load in the deploy scripts installed by vulcanize for each rubber module
Dir["#{File.dirname(__FILE__)}/rubber/deploy-*.rb"].each do |deploy_file|
  load deploy_file
end

# Deploy scripting
namespace :deploy do

  # Do a full deploy (start -> finish)
  task :full do
    update_code
    migrate
    assets.default
    create_symlink
    restart
    cleanup
  end

  # Rake assets
  namespace :assets do

    # Rake the configured directory
    task :default do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")
      migrate_target = fetch(:migrate_target, :latest)

      # Deploy assets off specified directory
      directory = case migrate_target.to_sym
        when :current then current_path
        when :latest  then latest_release
        else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
        end

      run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} assets:precompile"
    end

    # Rake the currently live directory
    task :current do
      migrate_target = fetch(:migrate_target, :latest)
      set :migrate_target, :current
      default
      set :migrate_target, migrate_target
    end

    # Allow items to silently fail if necessary
    rubber.allow_optional_tasks(self)
    tasks.values.each do |t|
      if t.options[:roles]
        task t.name, t.options, &t.body
      end
    end
  end

  # Roll back code to a previous revision
  namespace :rollback do
    task :default do
      revision
      restart
      cleanup
    end
  end

  # Handle chmodding of certain directories
  namespace :chmod do
    task :uploads do
      run "cd #{current_path};RAILS_ENV=#{rails_env} chmod -Rf 0777 public/uploads"
    end

    task :all do
      uploads
    end
  end

  # Allow items to silently fail if necessary
  rubber.allow_optional_tasks(self)
  tasks.values.each do |t|
    if t.options[:roles]
      task t.name, t.options, &t.body
    end
  end
end

# Rubber config hacks
namespace :rubber do

  # Delete the already existing config task
  tasks.replace(tasks.delete_if{|k,v| k.to_sym == :config})
  if all_methods.include?(:config)
    metaclass = class << self; self; end
    metaclass.send(:remove_method, :config)
  end

  # Store the two config options
  namespace :config do

    # Config based on the latest code
    task :default do
      opts = {}
      opts[:no_post] = true if ENV['NO_POST']
      opts[:force] = true if ENV['FORCE']
      opts[:file] = ENV['FILE'] if ENV['FILE']
      migrate_target = fetch(:migrate_target, :latest)

      # Config off the specifed directory
      opts[:deploy_path] = case migrate_target.to_sym
        when :current then current_path
        when :latest then latest_release
        else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
        end

      run_config(opts)
    end

    # Config on the currently deployed code
    task :current, { :on_error => :continue } do
      migrate_target = fetch(:migrate_target, :latest)
      set :migrate_target, :current
      default
      set :migrate_target, migrate_target
    end
  end
end

# Handle websockets daemon
namespace :websockets do

  task :start do
    run "cd #{current_path};RAILS_ENV=#{rails_env} script/websockets start"
  end

  task :stop do
    run "cd #{current_path};RAILS_ENV=#{rails_env} script/websockets stop"
  end

  task :reload do
    stop
    start
  end

end

# Reload delayed job
before "deploy:create_symlink", "delayed_job:stop"
after "deploy:restart", "delayed_job:start"

# Reload websockets daemon
before "deploy:create_symlink", "websockets:stop"
after "deploy:restart", "websockets:start"

# Add chmod to after rubber:setup_app_permissions
after "rubber:setup_app_permissions", "deploy:chmod:all"

# Reconfigure rubber on rollback
after "deploy:rollback:revision", "rubber:config:current"
after "deploy:rollback:revision", "deploy:assets:current"
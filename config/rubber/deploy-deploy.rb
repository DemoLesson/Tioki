# Deploy scripting
namespace :deploy do
  
  # Do a full deploy (start -> finish)
  task :full do
    update_code
    migrate
    assets.default
    delayed_job.stop
    create_symlink
    restart
    cleanup
  end

  # Do a new deploy (Doesn't stop the websocket / delayed_job daemon)
  task :new do
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
  end

  # Roll back code to a previous revision
  namespace :rollback do
    rubber.allow_optional_tasks(self)

    task :default do
      websockets.stop
      delayed_job.stop
      revision
      restart
      cleanup
    end
  end

  # Handle chmodding of certain directories
  namespace :chmod do
    rubber.allow_optional_tasks(self)

    task :uploads do
      run "cd #{current_path};RAILS_ENV=#{rails_env} chmod -Rf 0777 public/uploads"
    end

    task :all do
      uploads
    end
  end

  namespace :solr do
    task :start do
      run "cd #{current_path};RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:start"
    end

    task :stop do
      run "cd #{current_path};RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:stop"
    end
  end
end
# Handle websockets daemon
namespace :websockets do
  rubber.allow_optional_tasks(self)

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

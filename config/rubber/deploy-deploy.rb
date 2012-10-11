namespace :deploy do
  namespace :db do
    desc <<-DESC
      Migrate the Database
    DESC
    task :migrate do
      rsudo "cd #{current_release} && RAILS_ENV=#{Rubber.env} #{fetch(:rake, 'rake')} db:migrate"
    end
  end

  namespace :passenger do
  	desc <<-DESC
      Reload the application code
    DESC
    task :reload do
      rsudo "touch #{current_path}/tmp/restart.txt"
    end
  end
end

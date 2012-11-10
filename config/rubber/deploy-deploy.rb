namespace :deploy do
  namespace :db do
    desc <<-DESC
      Migrate the Database
    DESC
    task :migrate do
      rsudo "cd #{current_release} && RAILS_ENV=#{Rubber.env} #{fetch(:rake, 'rake')} db:migrate"
    end
  end
end

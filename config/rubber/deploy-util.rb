namespace :rubber do
  desc <<-DESC
    Run rake tasks in the current current release
  DESC
  task :rake do
    rsudo "cd #{current_release} && RAILS_ENV=#{Rubber.env} #{fetch(:rake, 'rake')} " + ENV['COMMAND']
  end

  desc <<-DESC
    Chmod a directory in the rails root
  DESC
  task :chmod do
    rsudo "cd #{current_release} && RAILS_ENV=#{Rubber.env} chmod -Rf " + ENV['CHMOD']
  end
end

namespace :rubber do

  namespace :cramp do

      rubber.allow_optional_tasks(self)

      after "rubber:install_packages", "rubber:cramp:install"
      after "deploy:update_code", "rubber:cramp:update"

      task :install, :roles => :cramp do
        script = <<-ENDSCRIPT
          if [[ ! -d "#{rubber_env.cramp_dir}" ]]; then
            git clone #{rubber_env.cramp_git_repository} #{rubber_env.cramp_dir} --depth 1

            mkdir #{rubber_env.cramp_dir}/log
            mkdir #{rubber_env.cramp_dir}/tmp
          fi
        ENDSCRIPT

        puts script

        rubber.sudo_script 'install_cramp', script
      end

      task :update, :roles => :cramp do
        stop

        script = <<-ENDSCRIPT
          if [[ -d "#{rubber_env.cramp_dir}" ]]; then
            cd #{rubber_env.cramp_dir}; git pull
          fi
        ENDSCRIPT
        puts script

        rubber.sudo_script 'update_cramp', script
        
        start
      end

      task :bootstrap, :roles => :cramp do
        exists = capture("echo $(ls #{rubber_env.cramp_dir}/log 2> /dev/null)")
        if exists.strip.size == 0
          rubber.sudo_script 'bootstrap_cramp', <<-ENDSCRIPT
            cd #{rubber_env.cramp_dir}

            # Add puma to the Gemfile so we can run the server.
            echo "gem 'thin'" >> Gemfile
            bundle install
          ENDSCRIPT

          restart
        end
      end

      desc "Stops the cramp server"
      task :stop, :roles => :cramp, :on_error => :continue do
        rsudo "cd #{rubber_env.cramp_dir}; bundle exec thin -d -P #{rubber_env.cramp_pid} -p #{rubber_env.cramp_port} --timeout 0 -R config.ru stop"
      end

      desc "Starts the cramp server"
      task :start, :roles => :cramp do
        rsudo "cd #{rubber_env.cramp_dir}; bundle exec thin -d -P #{rubber_env.cramp_pid} -p #{rubber_env.cramp_port} --timeout 0 -R config.ru start"
      end

      desc "Restarts the cramp server"
      task :restart, :roles => :cramp do
        stop
        start
      end

  end

end

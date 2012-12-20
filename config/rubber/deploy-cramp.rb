namespace :rubber do

  namespace :cramp do

      rubber.allow_optional_tasks(self)

      after "rubber:install_packages", "rubber:cramp:install"

      task :install, :roles => :cramp do
        rubber.sudo_script 'install_cramp', <<-ENDSCRIPT
          if [[ ! -d "#{rubber_env.cramp_dir}" ]]; then
            git #{rubber_env.cramp_git_repository} –depth 1 #{rubber_env.cramp_prefix}

            mkdir #{rubber_env.cramp_dir}/log
            mkdir #{rubber_env.cramp_dir}/tmp
          fi
        ENDSCRIPT
      end

      task :bootstrap, :roles => :cramp do
        exists = capture("echo $(ls #{rubber_env.cramp_dir}/log 2> /dev/null)")
        if exists.strip.size == 0
          rubber.update_code_for_bootstrap

          rubber.run_config(:file => "role/cramp/", :force => true, :deploy_path => release_path)

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

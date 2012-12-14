Tioki
=====
Tioki (formerely DemoLesson) platform in it's entirety

Deploy Script Commands
======================
These are the commands for the deploy script

```sh
./script/deploy logs [staging|production]             # Tail the server logs
./script/deploy update [staging|production]           # Installs / Updates all packages and gems as well as stages new code from publishing. Bumps version too!
./script/deploy publish [staging|production]          # Publishes pending code from `./script/deploy update`
./script/deploy rollback [staging|production]         # Rolls all [staging|production] servers back to the previously live codebase
./script/deploy create <staging|production> [alias]   # Creates a new server in [staging|production] mode. With the specified alias.
./script/deploy create_staging                        # Creates a staging server
./script/deploy rake <staging|production> <command>   # Runs rake task on server. Command should be task without preceding "rake".
./script/deploy setup                                 # Installs / Updates Rubber and syncs /etc/hosts aliases
./script/deploy prep                                  # Runs Bundle Install + Rake Assets and DB Migrate
./script/deploy memory <staging|production>           # Shows memory statistics about all servers
```
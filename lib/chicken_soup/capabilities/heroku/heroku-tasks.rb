######################################################################
#                            HEROKU TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  heroku_tasks = [
    "deploy",
    "deploy:default",
    "deploy:initial",
    "deploy:restart",
    "deploy:migrate",
    "deploy:rollback",
    "deploy:rollback:default",
    "deploy:web:enable",
    "deploy:web:disable",
    "website:install",
    "website:remove",
    "db:drop",
    "heroku.db:backup",
    "db:reset_and_seed",
    "db:seed",
    "shell",
    "invoke"
  ]

  _cset :skip_backup_before_migration,  false
  _cset :db_backup_file_extension,      'dump'

  before    "heroku:db:migrate",      "heroku:db:backup"          unless skip_backup_before_migration

  # on :start, "heroku:raise_error", :except => heroku_tasks

  namespace :heroku do
    namespace :deploy do
      task :base do
        heroku.configuration.push
        heroku.deploy.update
        heroku.db.migrate
      end

      desc <<-DESC
        The standard deployment task.

        It will check out a new release of the code, run any pending migrations and
        restart the application.
      DESC
      task :default do
        heroku.deploy.base
        heroku.deploy.restart
      end

      task :update do
        `git push heroku-#{rails_env} #{branch}:master`
      end

      desc <<-DESC
        Restarts the application.
      DESC
      task :restart do
        `heroku restart --app #{deploy_site_name}`
      end

      desc <<-DESC
        Rolls back to a previous version and restarts.
      DESC
      namespace :rollback do
        task :default do
          `heroku rollback --app #{deploy_site_name}`
          deploy.restart
        end
      end

      namespace :web do
        desc "Removes the maintenance page to resume normal site operation."
        task :enable do
          `heroku maintenance:off --app #{deploy_site_name}`
        end

        desc "Diplays the maintenance page."
        task :disable do
          `heroku maintenance:on --app #{deploy_site_name}`
        end
      end

      desc "Prepare the server for deployment."
      task :initial do
        heroku.deploy.default
      end
    end

    namespace :db do
      desc <<-DESC
        Runs the migrate rake task.
      DESC
      task :migrate do
        `heroku run rake db:migrate --app #{deploy_site_name}`
      end

      desc "Removes the DB from the Server.  Also removes the user."
      task :drop do
        `heroku pg:reset --app #{deploy_site_name}`
      end

      namespace :pull do
        desc <<-DESC
          Creates an easy way to debug remote data locally.

          * Running this task will create a dump file of all the data in the specified
            environment.
          * Copy the dump file to the local machine
          * Drop and recreate all local databases
          * Import the dump file
          * Bring the local DB up-to-date with any local migrations
          * Prepare the test environment
        DESC
        task :default do
          heroku.db.backup.default
          heroku.db.pull.latest
        end

        desc <<-DESC
          Just like `db:pull` but doesn't create a new backup first.
        DESC
        task :latest do
          %x{curl -o ./tmp/`date --iso-8601=seconds`.#{db_backup_file_extension} `heroku pgbackups:url --app #{deploy_site_name}`}

          latest_local_db_backup = `ls -1t #{rails_root}/tmp/*.#{db_backup_file_extension} | head -n 1`.chomp

          puts 'Running `rake db:drop:all db:create:all` locally'
          `#{local_rake} db:drop:all db:create:all`
          puts "Running DB restore locally with the DB backup file data"
          `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d #{application}_development #{latest_local_db_backup}`
          puts "Running `rake db:migrate db:test:prepare` locally"
          `#{local_rake} db:migrate db:test:prepare`

          heroku.db.scrub
        end
      end

      namespace :backup do
        desc "Backup the database"
        task :default do
          `heroku pgbackups:capture --app #{deploy_site_name} --expire`
        end

        # desc "List database backups"
        # task :list do
        #   `heroku pgbackups --app #{deploy_site_name}`
        # end

        # desc "List database backups"
        # task :get do
        #   `wget \`heroku pgbackups:url $1 --app #{deploy_site_name}\` ./tmp/db_backups `
        # end

        # desc "List database backups"
        # task :remove do
        #   `heroku pgbackups:destroy $1 --app #{deploy_site_name}`
        # end
      end

      desc <<-DESC
        Calls the rake task `db:reset_and_seed` on the server for the given environment.

        Typically, this task will drop the DB, recreate the DB, load the development
        schema and then populate the DB by calling the `db:seed` task.

        Warning: This task cannot be called in production mode.  If you truely wish
                to run this in production, you'll need to log into the server and
                run the rake task manually or use Capistrano's `console` task.
      DESC
      desc "Reset database and seed fresh"
      task :reset_and_seed do
        abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
        heroku.db.backup
        `heroku pg:reset --app #{deploy_site_name}`
        heroku.db.seed
      end

      desc <<-DESC
        Calls the rake task `db:seed` on the server for the given environment.

        Typically, this task will populate the DB with valid data which is necessary
        for the initial production deployment.  An example may be that the `STATES`
        table gets populated with all the information about the States.

        Warning: This task cannot be called in production mode.  If you truely wish
                to run this in production, you'll need to log into the server and
                run the rake task manually or use Capistrano's `console` task.
      DESC
      task :seed do
        abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
        heroku.db.backup
        `heroku run rake db:seed --app #{deploy_site_name}`
      end

      desc <<-DESC
        Calls the rake task `db:scrub` locally.

        Usually, this will be run in conjunction with `db:pull` but may also be run
        in a standalone manner.
      DESC
      task :scrub do
        puts 'Running `rake db:scrub` locally'
        `#{local_rake} db:scrub`
      end
    end

    namespace :configuration do
      task :push do
        require 'figaro'

        Figaro.instance_variable_set(:@path, "#{rails_root}/config/application.yml")

        Figaro::Tasks::Heroku.new(deploy_site_name).invoke
      end
    end

    desc "Invoke a single command on the Heroku server."
    task :run do
      `heroku run #{ENV['COMMAND']} --app #{deploy_site_name}`
    end

    desc <<-DESC
      [internal] Raises an error if someone tries to run a task other than those
      that are valid for a Heroku deployment.
    DESC
    task :raise_error do
      abort "Deploying the #{rails_env} environment to Heroku.  This command is invalid."
    end
  end
end

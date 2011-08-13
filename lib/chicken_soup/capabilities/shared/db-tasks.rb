######################################################################
#                          COMMON DB TASKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  _cset(:db_root_password)    {Capistrano::CLI.password_prompt("Root Password For DB: ")}
  _cset(:db_app_password)     {Capistrano::CLI.password_prompt("App Password For DB: ")}

  run_task  "db:create",       :as => manager_username
  run_task  "db:drop",         :as => manager_username

  before    "deploy:cleanup",  "deploy:migrate"
  before    "deploy:migrate",  "db:backup"            unless skip_backup_before_migration


    namespace :backup do
      desc <<-DESC
        Calls the rake task `db:backup` on the server for the given environment.

        * The backup file is placed in a directory called `db_backups` under the `shared`
          directory by default.
        * The filenames are formatted with the timestamp of the backup.
        * After export, each file is zipped up using a bzip2 compression format.
      DESC
      task :default, :roles => :db, :only => {:primary => true} do
        run %Q{cd #{current_path} && BACKUP_DIRECTORY="#{db_backups_path}" BACKUP_FILE="#{current_release}" BACKUP_FILE_EXTENSION="#{db_backup_file_extension}" #{rake} db:backup}
      end
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
      task :default, :roles => :db, :only => {:primary => true} do
        db.backup.default
        db.pull.latest
      end

      desc <<-DESC
        Just like `db:pull` but doesn't create a new backup first.
      DESC
      task :latest, :roles => :db, :only => {:primary => true} do
        latest_backup = capture(%Q{ls #{db_backups_path} -xtC | head -n 1 | cut -d " " -f 1}).chomp

        download_compressed "#{db_backups_path}/#{latest_backup}", "#{rails_root}/tmp/#{latest_backup}", :once => true

        `rake db:drop:all db:create:all`
        `rails dbconsole development < #{rails_root}/tmp/#{latest_backup}`
        `rake db:migrate db:test:prepare`
      end
    end

    desc <<-DESC
      Calls the rake task `db:reset_and_seed` on the server for the given environment.

      Typically, this task will drop the DB, recreate the DB, load the development
      schema and then populate the DB by calling the `db:seed` task.

      Warning: This task cannot be called in production mode.  If you truely wish
              to run this in production, you'll need to log into the server and
              run the rake task manually or use Capistrano's `console` task.
    DESC
    task :reset_and_seed, :roles => :db do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      run "cd #{current_path} && #{rake} db:reset_and_seed"
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
    task :seed, :roles => :db do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      run "cd #{current_path} && #{rake} db:seed"
    end
  end
end

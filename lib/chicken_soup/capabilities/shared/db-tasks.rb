######################################################################
#                          COMMON DB TASKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  _cset(:db_root_password)    {Capistrano::CLI.password_prompt("Root Password For DB: ")}
  _cset(:db_app_password)     {Capistrano::CLI.password_prompt("App Password For DB: ")}

  run_task  "db:create",       :as => manager_username
  run_task  "db:drop",         :as => manager_username

  before    "deploy:cleanup",  "deploy:migrate"
  before    "deploy:migrate",  "db:backup"            unless skip_backup_before_migration

  after     "db:backup",       "db:backup:compress"   if autocompress_db_backups
  after     "db:backup",       "db:backup:cleanup"    if limit_db_backups

  namespace :db do
    namespace :backup do
      desc <<-DESC
        Calls the rake task `db:backup` on the server for the given environment.

        * The backup file is placed in a directory called `db_backups` under the `shared`
          directory by default.
        * The filenames are formatted with the timestamp of the backup.
        * After export, each file is zipped up using a bzip2 compression format.
      DESC
      task :default, :roles => :db, :only => {:primary => true} do
        run %Q{cd #{current_path} && BACKUP_DIRECTORY="#{db_backups_path}" BACKUP_FILE="#{release_name}" BACKUP_FILE_EXTENSION="#{db_backup_file_extension}" #{rake} db:backup}
      end

      desc <<-DESC
        If the user has decided they would like to limit the number of db backups
        that can exist on the system, this task is called to clean up any files
        which are over that limit.

        The oldest files are cleaned up first.
      DESC
      task :cleanup, :roles => :db, :only => {:primary => true} do
        number_of_backups = capture("ls #{db_backups_path} -1 | wc -l").chomp.to_i

        if number_of_backups > total_db_backup_limit
          backup_files_to_remove = capture("ls #{db_backups_path}/* -1t | tail -n #{number_of_backups - total_db_backup_limit}").chomp.split("\n")

          backup_files_to_remove.each do |file|
            run "rm -f #{file}"
          end
        end
      end

      namespace :compress do
        desc <<-DESC
          Compresses the most recent backup if it isn't already compressed.

          The compression format is bzip2.
        DESC
        task :default, :roles => :db, :only => {:primary => true} do
          run "bzip2 -zvck9 #{latest_db_backup} > #{latest_db_backup}.bz2 && rm -f #{latest_db_backup}" unless compressed_file?(latest_db_backup)

          # After compressing, the latest_db_backup is no longer the latest DB
          # backup so we need to reset it.
          reset! :latest_db_backup_file
          reset! :latest_db_backup
        end

        desc <<-DESC
          Compresses any uncompressed DB backups to help save space.

          The compression format is bzip2.
        DESC
        task :all, :roles => :db, :only => {:primary => true} do
          uncompressed_backup_files = capture("ls #{db_backups_path}/*.#{db_backup_file_extension} -1tr").chomp.split("\n")

          uncompressed_backup_files.each do |file|
            run "bzip2 -zvck9 #{file} > #{file}.bz2 && rm -f #{file}"
          end
        end
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
        db.scrub
      end

      desc <<-DESC
        Just like `db:pull` but doesn't create a new backup first.
      DESC
      task :latest, :roles => :db, :only => {:primary => true} do
        download_compressed "#{latest_db_backup}", "#{rails_root}/tmp/#{latest_db_backup_file}", :once => true

        latest_local_db_backup = `ls -1t #{rails_root}/tmp/*.#{db_backup_file_extension} | head -n 1`.chomp

        puts 'Running `rake db:drop:all db:create:all` locally'
        `#{local_rake} db:drop:all db:create:all`
        puts "Running `rails dbconsole development < #{latest_local_db_backup}` locally"
        `rails dbconsole development < #{latest_local_db_backup}`
        puts "Running `rake db:migrate db:test:prepare` locally"
        `#{local_rake} db:migrate db:test:prepare`
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

    desc <<-DESC
      Calls the rake task `db:scrub` locally.

      Usually, this will be run in conjunction with `db:pull` but may also be run
      in a standalone manner.
    DESC
    task :scrub, :roles => :db do
      puts 'Running `rake db:scrub` locally'
      `#{local_rake} db:scrub`
    end
  end
end

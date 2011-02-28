######################################################################
#                          COMMON DB TASKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  _cset(:db_root_password)    {Capistrano::CLI.password_prompt("Root Password For DB: ")}
  _cset(:db_app_password)     {Capistrano::CLI.password_prompt("App Password For DB: ")}

  run_task "db:create",       :as => "manager"
  run_task "db:drop",         :as => "manager"

  namespace :db do
    desc <<-DESC
      Calls the rake task `db:backup` on the server for the given environment.

      * The backup file is placed in a directory called `db_backups` under the `shared`
        directory by default.
      * The filenames are formatted with the timestamp of the backup.
      * After export, each file is zipped up using a bzip2 compression format.
    DESC
    task :backup do
      run "if [ ! -d #{shared_path}/db_backups ]; then mkdir #{shared_path}/db_backups; fi"
      run "cd #{current_path} && bundle exec rake BACKUP_DIRECTORY=#{shared_path}/db_backups RAILS_ENV=#{rails_env} db:backup"
    end

    desc <<-DESC
      Calls the rake task `db:reset_and_seed` on the server for the given environment.

      Typically, this task will drop the DB, recreate the DB, load the development
      schema and then populate the DB by calling the `db:seed` task.

      Warning: This task cannot be called in production mode.  If you truely wish
              to run this in production, you'll need to log into the server and
              run the rake task manually.
    DESC
    task :reset_and_seed do
      raise "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      run "cd #{current_path} && rake RAILS_ENV=#{rails_env} db:reset_and_seed"
    end

    desc <<-DESC
      Calls the rake task `db:seed` on the server for the given environment.

      Typically, this task will populate the DB with valid data which is necessary
      for the initial production deployment.  An example may be that the `STATES`
      table gets populated with all the information about the States.

      Warning: This task cannot be called in production mode.  If you truely wish
              to run this in production, you'll need to log into the server and
              run the rake task manually.
    DESC
    task :seed do
      raise "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      run "cd #{current_path} && rake RAILS_ENV=#{rails_env} db:seed"
    end
  end
end

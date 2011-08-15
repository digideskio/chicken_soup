######################################################################
#                              DB CHECKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary DB capabilities variables have been set up.
        DESC
        task :db do
          required_variables = [
            :skip_backup_before_migration,
            :db_backups_path,
            :db_backup_file_extension,
            :autocompress_db_backups,
            :limit_db_backups,
            :total_db_backup_limit
          ]

          verify_variables(required_variables)
        end
      end
    end

    namespace :deployment do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if the DB is ready for deployment.
        DESC
        task :db, :roles => :db, :only => {:primary => true} do
          backup_task_exists = capture("cd #{current_path} && #{rake} -T | grep db:backup | wc -l").chomp
          abort("There must be a task named db:backup in order to deploy.  If you do not want to backup your DB during deployments, set the skip_backup_before_migration variable to true in your deploy.rb.") if backup_task_exists == '0'

          run "if [ ! -d #{db_backups_path} ]; then mkdir #{db_backups_path}; fi"
        end
      end
    end
  end
end

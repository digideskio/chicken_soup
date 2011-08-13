######################################################################
#                             DB DEFAULTS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for DB deployments."
      task :db do
        _cset :skip_backup_before_migration,  false

        _cset :db_backups_path,               "#{shared_path}/db_backups"
        _cset :db_backup_file_extension,      "dump.sql"

      end
    end
  end
end

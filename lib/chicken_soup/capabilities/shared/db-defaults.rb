######################################################################
#                             DB DEFAULTS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for DB deployments."
      task :db do
        _cset :skip_backup_before_migration,  false
        _cset :db_backups_path,               "#{shared_path}/db_backups"
      end
    end
  end
end

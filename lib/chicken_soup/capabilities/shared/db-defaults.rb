######################################################################
#                             DB DEFAULTS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for DB deployments."
      task :db do
        _cset :skip_backup_before_migration,  false
      end
    end
  end
end

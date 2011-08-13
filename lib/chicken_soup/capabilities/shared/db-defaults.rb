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

        _cset :autocompress_db_backups,       true

        set(:latest_db_backup_file)           {capture(%Q{ls #{db_backups_path} -xtC | head -n 1 | cut -d " " -f 1}).chomp}

        _cset :limit_db_backups,              true
        _cset :total_db_backup_limit,         100
      end
    end
  end
end

######################################################################
#                           LOG DEFAULTS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :tools do
    namespace :defaults do
      task :log do
        _cset(:web_server_error_log_files)  { find_all_logs(web_server_log_directory, ChickenSoup::WebServer::STANDARD_ERROR_LOGS) }
        _cset(:web_server_access_log_files) { find_all_logs(web_server_log_directory, ChickenSoup::WebServer::STANDARD_ACCESS_LOGS) }
        _cset(:web_server_log_files)        { web_server_access_log_files + web_server_error_log_files }
        _cset(:web_server_log_directory)    { log_directory(ChickenSoup::WebServer::STANDARD_LOG_LOCATIONS) }

        _cset(:app_server_log_files)        { find_all_logs(web_server_log_directory, ChickenSoup::ApplicationServer::STANDARD_LOGS) }

        _cset(:rails_log_files)             { ["#{shared_path}/log/#{rails_env}.log"] }

        _cset(:log_files)                   { rails_log_files + app_server_log_files + web_server_log_files }
      end
    end
  end
end

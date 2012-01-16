######################################################################
#                       WEB SERVER DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets common defaults for web servers."
      task :web_server do
        _cset(:web_server_control_script)   { WebServer::STANDARD_CONTROL_SCRIPTS.detect { |f| remote_file_exists? f } }
      end
    end
  end
end

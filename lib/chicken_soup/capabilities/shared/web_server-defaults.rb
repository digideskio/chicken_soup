######################################################################
#                       WEB SERVER DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  _cset(:web_server_control_script)   { WebServer::STANDARD_CONTROL_SCRIPTS.detect { |f| remote_directory_exists? f } }
end

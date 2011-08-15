######################################################################
#                          APACHE DEFAULTS                           #
######################################################################
module ChickenSoup
  module WebServer
    STANDARD_CONTROL_SCRIPTS = ['/usr/sbin/apachectl', '/usr/sbin/apache2', '/usr/sbin/httpd']
    STANDARD_LOG_LOCATIONS   = ['/var/log/apache2', '/var/log/httpd', '/etc/httpd/logs']
    STANDARD_ERROR_LOGS      = ['error_log', 'error.log', 'httpd-error.log']
    STANDARD_ACCESS_LOGS     = ['access_log', 'access.log', 'httpd-access.log']
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  require   'chicken_soup/capabilities/shared/web_server-defaults'

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Apache deployments."
      task :apache do
        capabilities.defaults.web_server

        if web_server_control_script =~ /apache2/
          set :apache_enable_script,    "a2ensite"
          set :apache_disable_script,   "a2dissite"
        end
      end
    end
  end
end

######################################################################
#                          APACHE DEFAULTS                           #
######################################################################
module ChickenSoup
  module WebServer
    STANDARD_CONTROL_SCRIPTS = ['/usr/sbin/apachectl', '/usr/sbin/apache2', '/usr/sbin/httpd']
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  require   'chicken_soup/capabilities/shared/web_server-defaults'

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Apache deployments."
      task :apache do
        if web_server_control_script =~ /apache2/
          set :apache_enable_script,    "a2ensite"
          set :apache_disable_script,   "a2dissite"
        end
      end
    end
  end
end

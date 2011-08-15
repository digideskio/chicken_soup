######################################################################
#                           NGINX DEFAULTS                           #
######################################################################
module ChickenSoup
  module WebServer
    STANDARD_CONTROL_SCRIPTS = ['/etc/init.d/nginx']
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  require   'chicken_soup/capabilities/shared/web_server-defaults'

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Checks to see what type of Nginx installation is running on the remote."
      task :nginx do
        capabilities.defaults.web_server
      end
    end
  end
end

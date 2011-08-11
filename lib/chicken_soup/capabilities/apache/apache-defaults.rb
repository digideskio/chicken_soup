######################################################################
#                          APACHE DEFAULTS                           #
######################################################################
module ChickenSoup
  def find_web_server_control_script
    if remote_file_exists?("/usr/sbin/apachectl")
      set :web_server_control_script,   "/usr/sbin/apachectl"
    elsif remote_file_exists?("/usr/sbin/apache2")
      set :web_server_control_script,   "/usr/sbin/apache2"
    elsif remote_file_exists?("/usr/sbin/httpd")
      set :web_server_control_script,   "/usr/sbin/httpd"
    end

    abort "Couldn't figure out how to control your installation of Apache" unless exists?(:web_server_control_script)
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Apache deployments."
      task :apache do
        find_web_server_control_script

        if web_server_control_script =~ /apache2/
          set :apache_enable_script,    "a2ensite"
          set :apache_disable_script,   "a2dissite"
        end
      end
    end
  end
end

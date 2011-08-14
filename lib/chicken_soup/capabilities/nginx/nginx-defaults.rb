######################################################################
#                           NGINX DEFAULTS                           #
######################################################################
module ChickenSoup
  def find_web_server_control_script
    if remote_file_exists?("/etc/init.d/nginx")
      set :web_server_control_script,   "/etc/init.d/nginx"
    end

    abort "Couldn't figure out how to control your installation of Nginx" unless exists?(:web_server_control_script)
  end
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Checks to see what type of Nginx installation is running on the remote."
      task :nginx do
        find_web_server_control_script
      end
    end
  end
end

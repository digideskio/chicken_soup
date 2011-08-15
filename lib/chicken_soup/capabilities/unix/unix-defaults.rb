######################################################################
#                         UNIX SERVER DEFAULTS                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for unix server deployments."
      task :unix do
        _cset :deployment_username,   "deploy"
        _cset :manager_username,      "manage"
        _cset :user,                  deployment_username

        _cset :user_home,             "/home/#{user}"
        _cset :manager_user_home,     "/home/#{manager_username}"
        _cset :deployment_user_home,  "/home/#{deployment_username}"
        _cset :deploy_base_dir,       "/var/www"
        _cset :deploy_site_name,      domain
        set   :deploy_to,             "#{deploy_base_dir}/#{deploy_site_name}"

        _cset :default_server_name,   domain
        _cset(:default_server_ip)     { lookup_ip_for default_server_name }

        _cset(:app_server_name)       { default_server_name }
        _cset(:web_server_name)       { default_server_name }
        _cset(:db_server_name)        { default_server_name }

        _cset(:app_server_ip)         { lookup_ip_for app_server_name }
        _cset(:web_server_ip)         { lookup_ip_for web_server_name }
        _cset(:db_server_ip)          { lookup_ip_for db_server_name  }

        # Evidently roles can't be assigned in a namespace :-/
        set_unix_server_roles
      end
    end
  end

  desc "[internal] This task is only here because `role` cannot be used within a `namespace`"
  task :set_unix_server_roles do
    role :web,                  web_server_name
    role :app,                  app_server_name
    role :db,                   db_server_name, :primary => true
  end
end

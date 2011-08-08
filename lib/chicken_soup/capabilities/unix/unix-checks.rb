######################################################################
#                             UNIX CHECKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary unix environment variables have been set up.
        DESC
        task :unix do
          required_variables = [
            :user,
            :deployment_username,
            :manager_username,
            :user_home,
            :deployment_user_home,
            :manager_user_home,
            :deploy_base_dir,
            :deploy_site_name,
            :deploy_to,
            :app_server_ip,
            :web_server_ip,
            :db_server_ip,
            :web_servers,
            :app_servers,
            :db_servers
          ]

          verify_variables(required_variables)
        end
      end
    end
  end
end

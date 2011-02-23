######################################################################
#                         ENVIRONMENT CHECKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :check do
      desc <<-DESC
        [internal] Checks to see if all necessary managed server environment variables have been set up.
      DESC
      task :managed_server do
        required_variables = [
          :ruby_version,
          :ruby_gemset,
          :rvm_ruby_string,
          :passenger_version,
          :gem_packager_version,
          :user,
          :deployment_username,
          :manager_username,
          :user_home,
          :manager_user_home,
          :deploy_dir,
          :deploy_name,
          :deploy_to,
          :app_server_ip,
          :web_server_ip,
          :db_server_ip,
          :web_server_name,
          :app_server_name,
          :db_server_name,
          :capabilities
        ]

        verify_variables(required_variables)
      end

      desc <<-DESC
        [internal] Checks to see if all necessary Heroku environment variables have been set up.
      DESC
      task :heroku do
        required_variables = [
          :deploy_name,
          :user
        ]

        verify_variables(required_variables)
      end

      desc "[internal] Checks for environment variables shared among all deployment types."
      task :common do
        abort "You need to specify staging or production when you deploy. ie 'cap staging db:backup'" unless exists?(:rails_env)
        abort "You need to specify a deployment type in your application's 'deploy.rb' file. ie 'set :deployment_type, :heroku'" unless exists?(:deployment_type)

        required_variables = [
          :application,
          :application_short
        ]

        verify_variables(required_variables)
      end

      desc "[internal] Checks to see if all the necessary environment variables have been set up for a proper deployment."
      task :default do
        environment.check.send(deployment_type.to_s)
      end
    end
  end
end

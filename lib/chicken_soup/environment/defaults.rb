######################################################################
#                      DEFAULT ENVIRONMENT SETUP                     #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :defaults do
      desc "[internal] Used to set up the intelligent staging defaults we like for our projects"
      task :staging do
        set :rails_env,             "staging"
      end

      desc "[internal] Used to set up the intelligent production defaults we like for our projects"
      task :production do
        set :rails_env,             "production"
      end

      desc "[internal] Sets intelligent defaults for managed server deployments."
      task :managed_server do
        set :deployment_username,   "deploy"                            unless exists?(:deployment_username)
        set :manager_username,      "manager"                           unless exists?(:manager_username)
        set :user,                  deployment_username                 unless exists?(:user)

        set :user_home,             "/home/#{user}"                     unless exists?(:user_home)
        set :manager_user_home,     "/home/#{manager_username}"         unless exists?(:manager_user_home)
        set :deployment_user_home,  "/home/#{deployment_username}"      unless exists?(:deployment_user_home)
        set :deploy_dir,            "/var/www"                          unless exists?(:deploy_dir)
        set :deploy_name,           "#{application_short}.#{domain}"    unless exists?(:deploy_name)
        set :deploy_to,             "#{deploy_dir}/#{deploy_name}"

        set :keep_releases,         15

        set :global_shared_files,   ["config/database.yml"]             unless exists?(:global_shared_files)

        set :app_server_ip,         server_ip                           unless exists?(:app_server_ip)
        set :web_server_ip,         server_ip                           unless exists?(:web_server_ip)
        set :db_server_ip,          server_ip                           unless exists?(:db_server_ip)

        set :app_server_name,       server_name                         unless exists?(:app_server_name)
        set :web_server_name,       server_name                         unless exists?(:web_server_name)
        set :db_server_name,        server_name                         unless exists?(:db_server_name)

        # Evidently roles can't be assigned in a namespace :-/
        set_managed_server_roles
      end

      desc "[internal] Sets intelligent defaults for Heroku deployments"
      task :heroku do
        set :heroku_credentials_path,   "#{ENV["HOME"]}/.heroku"                                          unless exists?(:heroku_credentials_path)
        set :heroku_credentials_file,   "#{heroku_credentials_path}/credentials"                          unless exists?(:heroku_credentials_file)

        set(:password)                  {Capistrano::CLI.password_prompt("Encrypted Heroku Password: ")}  unless exists?(:password)

        set :capabilities,              [:heroku]
      end

      desc "[internal] Sets intelligent version control defaults for deployments"
      task :vc do
        set :scm,                         :git
        set :github_account,              "#{application}" unless exists?(:github_account)
        set(:repository)                  {"git@github.com:#{github_account}/#{application}.git"}
        set(:branch)                      { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        set(:remote)                      { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }
        set :deploy_via,                  :remote_cache
        ssh_options[:forward_agent]       = true
      end

      desc "[internal] Sets intelligent common defaults for deployments"
      task :common do
        set :use_sudo,                    false
        set :default_shell,               false

        set :copy_compression,            :bz2

        set(:application_underscored)     {application.gsub(/-/, "_")} unless exists?(:application_underscored)
      end

      desc <<-DESC
        [internal] Installs the entire environment for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
        Unfortunately some of them can't be such as :scm but they're our recipies so...
        LIVE WITH IT! :)
      DESC
      task :default do
        defaults.common
        defaults.vc
        defaults.send(deployment_type.to_s)
      end
    end
  end

  desc "[internal] This task is only here because `role` cannot be used within a `namespace`"
  task :set_managed_server_roles do
    role :web,                  web_server_name, :primary => true
    role :app,                  app_server_name, :primary => true
    role :db,                   db_server_name,  :primary => true
  end
end

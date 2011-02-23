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
        _cset :deployment_username,   "deploy"
        _cset :manager_username,      "manager"
        _cset :user,                  deployment_username

        _cset :user_home,             "/home/#{user}"
        _cset :manager_user_home,     "/home/#{manager_username}"
        _cset :deployment_user_home,  "/home/#{deployment_username}"
        _cset :deploy_dir,            "/var/www"
        _cset :deploy_name,           "#{application_short}.#{domain}"
        set   :deploy_to,             "#{deploy_dir}/#{deploy_name}"

        _cset :keep_releases,         15

        _cset :global_shared_files,   ["config/database.yml"]

        _cset :app_server_ip,         server_ip
        _cset :web_server_ip,         server_ip
        _cset :db_server_ip,          server_ip

        _cset :app_server_name,       server_name
        _cset :web_server_name,       server_name
        _cset :db_server_name,        server_name

        # Evidently roles can't be assigned in a namespace :-/
        set_managed_server_roles
      end

      desc "[internal] Sets intelligent defaults for Heroku deployments"
      task :heroku do
        _cset :heroku_credentials_path,   "#{ENV["HOME"]}/.heroku"
        _cset :heroku_credentials_file,   "#{heroku_credentials_path}/credentials"

        _cset(:password)                  {Capistrano::CLI.password_prompt("Encrypted Heroku Password: ")}

        set :capabilities,                [:heroku]
      end

      desc "[internal] Sets intelligent version control defaults for deployments"
      task :vc do
        _cset :github_account,            "#{application}"
        _cset :deploy_via,                :remote_cache

        set :scm,                         :git
        set(:repository)                  {"git@github.com:#{github_account}/#{application}.git"}
        set(:branch)                      { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        set(:remote)                      { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }
        ssh_options[:forward_agent]       = true
      end

      desc "[internal] Sets intelligent common defaults for deployments"
      task :common do
        set :use_sudo,                    false
        set :default_shell,               false

        set :copy_compression,            :bz2

        _cset(:application_underscored)   {application.gsub(/-/, "_")}
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

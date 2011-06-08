######################################################################
#                             UNIX TASKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before "deploy:config:symlink",                 "deploy:config:create"

  namespace :deploy do
    namespace :config do
      desc <<-DESC
        Creates the directory where the `symlink` task will look for its configuration files.

        It will first look in the local Rails directory to see if there is
        a file of the same name as one of the shared files with the deployment environment
        appended on the end.

        For example, if you had `config/database.yml` as one of your global_shared_files and
        you were deploying to the `staging` environment, this task will look for:

            \#{Rails.root}/config/database.yml.staging

        If it finds it, it will upload the file to the shared directory on the server.

        If it doesn't find it, it will check to see if the remote file exists and finally,
        if not, it will just create an empty file.
      DESC
      task :create do
        run "if [ ! -d #{shared_path}/config ]; then mkdir -p #{shared_path}/config; fi"

        global_shared_files.each do |shared_file|
          local_shared_file = "#{Dir.pwd}/#{shared_file}.#{rails_env}"

          if File.exists?(local_shared_file)
            top.upload(local_shared_file, "#{shared_path}/#{shared_file}", :mode => "600")
          elsif !remote_file_exists?("#{shared_path}/#{shared_file}")
            run "touch #{shared_path}/#{shared_file}"
          end
        end
      end

      desc <<-DESC
        Symlinks sensitive configuration files which shouldn't be checked into source control.

        By default, these live in the shared directory that Capistrano sets up.
      DESC
      task :symlink do
        global_shared_files.each do |shared_file|
          run "ln -nfs #{shared_path}/#{shared_file} #{latest_release}/#{shared_file}"
        end
      end
    end
  end

  namespace :os do
    namespace :users do
      namespace :superuser do
        desc <<-DESC
          [internal] Switches Capistrano to use the superuser account for all subsequent SSH actions.

          It will prompt for the superuser's password the first time it's needed.
        DESC
        task :use do
          set_user_to("root")
        end
      end

      namespace :manager do
        desc <<-DESC
          [internal] Switches Capistrano to use the manager user for all subsequent SSH actions.

          It will prompt for the manager user's password the first time it's needed.
          (If public key authentication is already installed, you will not be prompted.)
        DESC
        task :use do
          set_user_to(manager_username)
        end
      end

      namespace :deploy do
        desc <<-DESC
          [internal] Switches Capistrano to use the deployment user for all subsequent SSH actions.

          It will prompt for the deployment user's password the first time it's needed.
          (If public key authentication is already installed, you will not be prompted.)
        DESC
        task :use do
          set_user_to(deployment_username)
        end
      end
    end
  end
end

######################################################################
#                             UNIX CHECKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
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
          :web_server_name,
          :app_server_name,
          :db_server_name
        ]

        verify_variables(required_variables)
      end
    end
  end
end

######################################################################
#                         UNIX SERVER DEFAULTS                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for unix server deployments."
      task :unix do
        _cset :deployment_username,   "deploy"
        _cset :manager_username,      "manager"
        _cset :user,                  deployment_username

        _cset :user_home,             "/home/#{user}"
        _cset :manager_user_home,     "/home/#{manager_username}"
        _cset :deployment_user_home,  "/home/#{deployment_username}"
        _cset :deploy_base_dir,       "/var/www"
        _cset :deploy_site_name,      domain
        set   :deploy_to,             "#{deploy_base_dir}/#{deploy_site_name}"

        _cset :app_server_ip,         default_server_ip
        _cset :web_server_ip,         default_server_ip
        _cset :db_server_ip,          default_server_ip

        _cset :default_server_name,   domain

        _cset(:app_server_name)       { default_server_name }
        _cset(:web_server_name)       { default_server_name }
        _cset(:db_server_name)        { default_server_name }

        # Evidently roles can't be assigned in a namespace :-/
        set_unix_server_roles
      end
    end
  end

  desc "[internal] This task is only here because `role` cannot be used within a `namespace`"
  task :set_unix_server_roles do
    role :web,                  web_server_name, :primary => true
    role :app,                  app_server_name, :primary => true
    role :db,                   db_server_name,  :primary => true
  end
end

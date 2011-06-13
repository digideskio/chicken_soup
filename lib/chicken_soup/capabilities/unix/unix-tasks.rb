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

      namespace :manage do
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

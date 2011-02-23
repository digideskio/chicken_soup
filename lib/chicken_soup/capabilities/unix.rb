######################################################################
#                         COMMON *NIX TASKS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before "deploy:config:symlink",                 "deploy:config:create"

  namespace :deploy do
    namespace :config do
      desc <<-DESC
        Creates the directory where the `symlink` task will look for its configuration files.

        It will first look in the user's home directory to see if there is
        a file of the same name as one of the shared files. If there is, it
        will move that to the shared location.  If not, it will create an
        empty file.
      DESC
      task :create do
        run "if [ ! -d #{shared_path}/config ]; then mkdir -p #{shared_path}/config; fi"

        global_shared_files.each do |shared_file|
          local_shared_file = "#{shared_file}.#{rails_env}"

          if File.exists?(local_shared_file)
            top.upload(local_shared_file, "#{shared_path}/#{shared_file}", :mode => "600")
          else
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
      namespace :root do
        desc <<-DESC
          [internal] Switches Capistrano to use the root user for all subsequent SSH actions.

          It will prompt for the root user's password the first time it's needed.
          (If the Kompanee Bash environment has been installed, you will no longer
          be able to log in as root.)
        DESC
        task :use do
          set_user_to("root")
        end
      end

      namespace :manager do
        desc <<-DESC
          Switches Capistrano to use the manager user for all subsequent SSH actions.

          It will prompt for the manager user's password the first time it's needed.
          (If public key authentication is already installed, you will not be prompted.)
        DESC
        task :use do
          set_user_to(manager_username)
        end
      end

      namespace :deploy do
        desc <<-DESC
          Switches Capistrano to use the deployment user for all subsequent SSH actions.

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

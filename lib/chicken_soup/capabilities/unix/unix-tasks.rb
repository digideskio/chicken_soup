######################################################################
#                             UNIX TASKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before "deploy:shared_files:symlink",        "deploy:shared_files:setup"

  namespace :unix do
    namespace :deploy do
      task :base do
        deploy.update
        unix.deploy.shared_files.symlink
        gems.install
        deploy.cleanup
      end

      task :subzero do
        ruby.update
        deploy.base
      end

      task :initial do
        deploy.setup
        db.create
        website.install
        deploy.cold
        deploy.check
      end

      task :default do
        deploy.base
        deploy.restart
      end
    end

    namespace :shared_files do
      desc <<-DESC
        Creates the directory where the `symlink` task will look for its configuration files.

        It will first look in the local Rails directory to see if there is
        a file or directory of the same name as one of the shared files with the deployment
        environment appended on the end.

        For example, if you had `config/database.yml` as one of your
        global_shared_elements and you were deploying to the `staging` environment, this
        task will look for:

            \#{Rails.root}/config/database.yml.staging

        If it finds it, it will upload the file or directory to the shared directory on
        the server and rename it to the proper file name.

        If it doesn't find it, it will check to see if the remote file exists.

        As a last resort, it will error out because the symlink task which follows will
        fail due to the missing file.

        Note: This task will also work for setting up shared directories for user uploads, etc.
      DESC
      task :setup, :roles => :app do
        global_shared_elements.each do |shared_file|
          base_dir_of_shared_file         = shared_file.match(%r{/?((?:.*)/)})[1]
          run "mkdir -p '#{shared_path}/#{base_dir_of_shared_file}'"

          remote_shared_file              = "#{shared_path}/#{shared_file}"
          local_shared_file               = "#{rails_root}/#{shared_file}"
          local_environment_specific_file = "#{local_shared_file}.#{rails_env}"
          permissions                     = File.directory? local_shared_file ? "755" : "600"

          if File.exists?(local_environment_specific_file)
            top.upload(local_environment_specific_file, remote_shared_file, :mode => permissions)
          elsif !remote_file_exists?(remote_shared_file)
            abort "I'm sorry Dave, but I couldn't find a local file or directory at '#{local_environment_specific_file}' or on the remote server at '#{remote_shared_file}'"
          end
        end
      end

      desc <<-DESC
        Symlinks sensitive configuration files which shouldn't be checked into source control.

        By default, these live in the shared directory that Capistrano sets up.
      DESC
      task :symlink, :roles => :app do
        global_shared_elements.each do |shared_file|
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

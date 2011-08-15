######################################################################
#                             RVM TASKS                              #
######################################################################
module ChickenSoup
  def run_with_ruby_manager(ruby_env_string, command, options = {})
    run "rvm use #{ruby_env_string} && #{command}", options
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  run_task 'ruby:update', :as => manager_username

  namespace :ruby do
    desc <<-DESC
      During the deployment, the wrapper ruby executable used by the
      application server will be switched to utilize the ruby sepecified
      by the application.

      Note: This is only available during a subzero deployment since the web
      server will need to be restarted in order for the changes to take effect.
    DESC
    task :update do
      if ruby_version_update_pending
        after   'ruby:update',    'gems:clean', 'gems:install'

        set     :ruby_version_update_pending,   false

        run("rvm use --create #{full_ruby_environment_string}")
        run("rvm wrapper #{full_ruby_environment_string} #{application_server_type}")
      else
        set     :ruby_version_update_pending,   true
      end
    end
  end
end

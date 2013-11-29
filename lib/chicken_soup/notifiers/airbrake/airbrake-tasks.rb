######################################################################
#                       AIRBRAKE NOTIFIER TASKS                      #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after 'deploy',       'notify:via_airbrake'

  namespace :notify do
    desc <<-DESC
      [internal] Sends Airbrake information regarding the deployment.
      If you have a paid version of Airbrake, it will resolve all of
      your errors.
    DESC
    task :via_airbrake, :except => { :no_release => true } do
      notify_command = "rake airbrake:deploy TO=#{rails_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
      notify_command << " DRY_RUN=true" if dry_run
      notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']

      `#{notify_command}`
    end
  end
end

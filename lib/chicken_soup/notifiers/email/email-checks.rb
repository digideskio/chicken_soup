######################################################################
#                       EMAIL NOTIFIER CHECKS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :notifiers do
    namespace :check do
      desc <<-DESC
        [internal] Checks to see if all necessary email notification environment variables have been set up.
      DESC
      task :email do
        required_variables = [
          :email_notifier_recipients,
          :email_notifier_domain,
          :email_notifier_username,
          :email_notifier_password
        ]

        verify_variables(required_variables)
      end
    end
  end
end

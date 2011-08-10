######################################################################
#                       EMAIL NOTIFIER CHECKS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  namespace :notifiers do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary email notification environment variables have been set up.
        DESC
        task :email do
          required_variables = [
            :email_notifier_client_recipients,
            :email_notifier_internal_recipients,
            :email_notifier_domain,
            :email_notifier_username,
            :email_notifier_password,
            :vc_log
          ]

          abort "You must specify either internal or client recipients in order to use the email notifier." if email_notifier_client_recipients.empty? && email_notifier_internal_recipients.empty?

          verify_variables(required_variables)
        end
      end
    end
  end
end

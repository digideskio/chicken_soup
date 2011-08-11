######################################################################
#                        EMAIL NOTIFIER TASKS                        #
######################################################################
require 'mail'

Capistrano::Configuration.instance(:must_exist).load do |cap|
  after     'deploy',                 'notify:via_email'

  namespace :notify do
    desc <<-DESC
      [internal] Sends a notification via email once a deployment is complete.
    DESC
    task :via_email do
      Mail.defaults do
        delivery_method cap[:email_notifier_mail_method], cap[:email_notifier_mail_options]
      end

      if !cap[:email_notifier_client_recipients].empty?
        Mail.deliver do
              to cap[:email_notifier_client_recipients]
            from cap[:email_notifier_sender]
         subject cap[:email_notifier_subject]
            body cap[:email_notifier_client_body]
        end
      end

      if !cap[:email_notifier_internal_recipients].empty?
        Mail.deliver do
              to cap[:email_notifier_internal_recipients]
            from cap[:email_notifier_sender]
         subject cap[:email_notifier_subject]
            body cap[:email_notifier_internal_body]
        end
      end
    end
  end
end

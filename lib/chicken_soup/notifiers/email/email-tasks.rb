######################################################################
#                        EMAIL NOTIFIER TASKS                        #
######################################################################
require 'mail'

Capistrano::Configuration.instance(:must_exist).load do |cap|
  before    'notify:by_email',            'vc:log'
  before    'deploy:clean',               'notify:by_email'

  namespace :notify do
    desc <<-DESC
      [internal] Sends a notification via email once a deployment is complete.
    DESC
    task :by_email do
      Mail.deliver do
             to cap[:email_notifier_recipients]
           from cap[:email_notifier_sender]
        subject cap[:email_notifier_subject]
           body cap[:email_notifier_body]
      end
    end
  end
end

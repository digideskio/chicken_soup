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

######################################################################
#                       EMAIL NOTIFIER DEFAULTS                      #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do |cap|
  namespace :notifiers do
    namespace :defaults do
      task :email do
        _cset(:email_notifier_domain)         {ENV['CHICKEN_SOUP_EMAIL_DOMAIN']}
        _cset(:email_notifier_username)       {ENV['CHICKEN_SOUP_EMAIL_USERNAME']}
        _cset(:email_notifier_password)       {ENV['CHICKEN_SOUP_EMAIL_PASSWORD']}

        _cset :email_notifier_method,         :smtp
        _cset :email_notifier_server,         "smtp.gmail.com"
        _cset :email_notifier_port,           587
        _cset :email_notifier_authentication, 'plain'

        _cset :email_notifier_options,      { :address              => email_notifier_server,
                                              :port                 => email_notifier_port,
                                              :domain               => email_notifier_domain,
                                              :user_name            => email_notifier_username,
                                              :password             => email_notifier_password,
                                              :authentication       => email_notifier_authentication,
                                              :enable_starttls_auto => true  }

        _cset :email_notifier_sender,         'theshadow@theshadowknows.com'
        _cset :email_notifier_subject,        "#{application.capitalize} has been deployed to #{rails_env.capitalize}"
        _cset :email_notifier_body,           <<-WERNERHEISENBERG
This is my deployment email
                                              WERNERHEISENBERG

        Mail.defaults do
          delivery_method cap[:email_notifier_method], cap[:email_notifier_options]
        end
      end
    end
  end
end

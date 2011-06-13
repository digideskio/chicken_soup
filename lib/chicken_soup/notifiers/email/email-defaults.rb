######################################################################
#                       EMAIL NOTIFIER DEFAULTS                      #
######################################################################
require 'mail'
require 'erb'
require 'chicken_soup/notifiers/email_notifier'

Capistrano::Configuration.instance(:must_exist).load do |cap|
  before    'notifiers:defaults:email',            'vc:log'

  namespace :notifiers do
    namespace :defaults do
      task :email do
        _cset :email_notifier_format,              'html'

        _cset :email_notifier_mail_method,         :smtp
        _cset :email_notifier_server,              "smtp.gmail.com"
        _cset :email_notifier_port,                587
        _cset :email_notifier_authentication,      'plain'

        _cset(:email_notifier_mail_options)      do
                                                    { :address              => email_notifier_server,
                                                      :port                 => email_notifier_port,
                                                      :domain               => email_notifier_domain,
                                                      :user_name            => email_notifier_username,
                                                      :password             => email_notifier_password,
                                                      :authentication       => email_notifier_authentication,
                                                      :enable_starttls_auto => true  }
                                                 end

        _cset :email_notifier_client_recipients,   []
        _cset :email_notifier_internal_recipients, []
        _cset :email_notifier_sender,              'theshadow@theshadowknows.com'
        _cset :email_notifier_subject,             "#{application.titleize} has been deployed to #{rails_env.capitalize}"
        _cset :email_notifier_client_template,     read_template("client_email.#{email_notifier_format}.erb")
        _cset :email_notifier_internal_template,   read_template("internal_email.#{email_notifier_format}.erb")

        email_notifier = ChickenSoup::EmailNotifier.new(cap)
        _cset :email_notifier_client_body,         render_erb(email_notifier_client_template, email_notifier)
        _cset :email_notifier_internal_body,       render_erb(email_notifier_internal_template, email_notifier)
      end
    end
  end
end

def render_erb(template, email_info)
  ERB.new(template, 0, "%<>").result(binding)
end

def read_template(template)
  File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', template))
end

######################################################################
#                         ENVIRONMENT CHECKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  on      :start,                                 'environment:check', :except => ['staging', 'production']

  before  'environment:check',                    'environment:check:common'

  namespace :environment do
    namespace :check do
      desc "[internal] Checks for environment variables shared among all deployment types."
      task :common do
        abort "You need to specify staging or production when you deploy. ie 'cap staging db:backup'" unless exists?(:rails_env)
        abort "You need to specify a deployment type in your application's 'deploy.rb' file. ie 'set :deployment_type, :heroku'" unless exists?(:deployment_type)

        required_variables = [
          :application,
          :application_short
        ]

        verify_variables(required_variables)
      end

      desc "[internal] Runs checks for all of the capabilities listed."
      task :capabilities do
        if exists?(:capabilities)
          fetch(:capabilities).each do |capability|
            environment.check.send(capability.to_s) if environment.check.respond_to?(capability.to_sym)
          end
        end
      end

      desc "[internal] Checks to see if all the necessary environment variables have been set up for a proper deployment."
      task :default do
        environment.check.capabilities
      end
    end
  end
end

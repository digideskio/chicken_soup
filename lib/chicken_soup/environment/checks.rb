######################################################################
#                         ENVIRONMENT CHECKS
#
# Sets up a first-pass environment check for the deployment.
#
# First, an environment MUST be present in order for any deployment
# to happen.  It's a safety measure that this is explicitly stated.
#
# It also checks to make sure that the :application and
# :application_short environment variables have been set.
#
# This happens before any of the capabilities have been added to the
# deployment and therefore that is all we know to check for at this
# point.
#
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  on      :start,               'environment:check',    :except => ['staging', 'production']

  after   'environment:check',  'capabilities:check'

  namespace :environment do
    desc "[internal] Checks for environment variables shared among all deployment types."
    task :check do
      abort "You need to specify staging or production when you deploy. ie 'cap staging db:backup'" unless exists?(:rails_env)
      abort "You need to specify a deployment type in your application's 'deploy.rb' file. ie 'set :deployment_type, :heroku'" unless exists?(:deployment_type)

      required_variables = [
        :application,
        :application_short
      ]

      verify_variables(required_variables)
    end
  end
end

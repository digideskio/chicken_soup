######################################################################
#                          ENVIRONMENT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/environment/defaults'
  require 'chicken_soup/environment/checks'
  require 'chicken_soup/environment/tasks'

  namespace :environment do
    desc "[internal] Load the Chicken Soup environment"
    task :init do
      environment.defaults
      environment.check
      environment.tasks
    end
  end
end

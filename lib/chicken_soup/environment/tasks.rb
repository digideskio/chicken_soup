######################################################################
#                         ENVIRONMENT TASKS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'load_capability_checks', 'load_capability_tasks'

  namespace :environment do
    desc "[internal] A helper task used to load the tasks for all of the capabilities."
    task :load_tasks do
    end
  end
end

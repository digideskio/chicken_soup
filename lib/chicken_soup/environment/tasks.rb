######################################################################
#                         ENVIRONMENT TASKS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after  'environment:load_tasks',      'capabilities:load_tasks', 'notifiers:load_tasks'

  namespace :environment do
    desc "[internal] A helper task used to load the tasks for all of the capabilities."
    task :load_tasks do
    end
  end
end

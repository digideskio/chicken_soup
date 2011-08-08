Capistrano::Configuration.instance(:must_exist).load do
  before  'notifiers:load_tasks',      'load_notifier_tasks'

  namespace :notifiers do
    desc <<-DESC
      [internal] A helper task used to load all of the tasks associated with the
      requested notifiers.
    DESC
    task :load_tasks do
    end

    desc <<-DESC
      Disables all notifiers for the current deployment.

      This task must be called prior to any of the `deploy` tasks.
    DESC
    task :disable do
      set :notifiers,     []
    end
  end
end

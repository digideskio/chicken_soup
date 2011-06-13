Capistrano::Configuration.instance(:must_exist).load do
  before  'notifiers:load_tasks',      'load_notifier_tasks'

  namespace :capabilities do
    desc <<-DESC
      [internal] A helper task used to load all of the tasks associated with the
      requested capabilities.
    DESC
    task :load_tasks do
    end
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  before  'tools:load_tasks',      'load_tool_tasks'

  namespace :tools do
    desc <<-DESC
      [internal] A helper task used to load all of the tasks associated with the
      requested tools.
    DESC
    task :load_tasks do
    end
  end
end

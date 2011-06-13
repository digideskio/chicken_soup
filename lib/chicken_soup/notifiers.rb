######################################################################
#                           NOTIFIERS SETUP                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/notifiers/defaults'
  require "chicken_soup/notifiers/checks"
  require "chicken_soup/notifiers/tasks"

  ['defaults', 'checks', 'tasks'].each do |method|
    desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
    task "load_notifier_#{method}".to_sym do
      fetch(:notifiers).each do |notifier|
        require_if_exists "chicken_soup/notifiers/#{capability}/#{notifier}-#{method}"
      end
    end
  end
end

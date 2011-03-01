######################################################################
#                           NOTIFIERS SETUP                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/notifiers/defaults'
  require "chicken_soup/notifiers/checks"

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_notifiers do
    fetch(:notifiers).each do |notifier|
      require "chicken_soup/notifiers/#{notifier}"
    end
  end
end

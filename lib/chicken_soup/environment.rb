######################################################################
#                          ENVIRONMENT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/environment/checks'
  require 'chicken_soup/environment/defaults'

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capabilities do
    require "chicken_soup/capabilities/unix"
    capabilities.each do |capability|
      require "chicken_soup/capabilities/#{capability}"
    end
  end
end

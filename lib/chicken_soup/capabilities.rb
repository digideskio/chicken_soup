######################################################################
#                         CAPABILITIES SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/defaults'
  require "chicken_soup/capabilities/checks"

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capabilities do
    require "chicken_soup/capabilities/#{deployment_type}"

    capabilities.each do |capability|
      require "chicken_soup/capabilities/#{capability}"
    end
  end
end

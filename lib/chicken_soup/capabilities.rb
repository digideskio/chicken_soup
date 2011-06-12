######################################################################
#                         CAPABILITIES SETUP
#
# Beginning here, the deployment will utilize the :capabilities array
# which should have been set in the deploy.rb file.  If :capabilites
# was not set, then nothing else is loaded.
#
# If it was set, we first load all of the default values for each
# capability's environment variables.
#
# Next, we verify that each capability has what it needs to proceed
# through the rest of the deployment.  If not, the deployment will
# abort.
#
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/defaults'
  require "chicken_soup/capabilities/checks"

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capability_defaults do
    require "chicken_soup/capabilities/#{deployment_type}-defaults"

    fetch(:capabilities).each do |capability|
      require "chicken_soup/capabilities/#{capability}-defaults"
    end
  end

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capability_checks do
    require "chicken_soup/capabilities/#{deployment_type}-checks"

    fetch(:capabilities).each do |capability|
      require "chicken_soup/capabilities/#{capability}-checks"
    end
  end

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capability_tasks do
    require "chicken_soup/capabilities/#{deployment_type}-tasks"

    fetch(:capabilities).each do |capability|
      require "chicken_soup/capabilities/#{capability}-tasks"
    end
  end
end

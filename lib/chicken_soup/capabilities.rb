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
  require "chicken_soup/capabilities/tasks"

  ['defaults', 'checks', 'tasks'].each do |method|
    desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
    task "load_capability_#{method}".to_sym do
      require_if_exists "chicken_soup/capabilities/#{deployment_type}/#{deployment_type}-#{method}"

      fetch(:capabilities).each do |capability|
        require_if_exists "chicken_soup/capabilities/#{capability}/#{capability}-#{method}"
      end
    end
  end
end

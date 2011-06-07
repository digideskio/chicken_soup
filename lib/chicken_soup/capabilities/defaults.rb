######################################################################
#                     DEFAULT CAPABILITIES SETUP
#
# The 'capabilities:defaults' task hooks itself into the deployment
# stream by attaching an after hook to 'environment:defaults'.
#
# Prior to execution, all of the capabilities which were specified in
# the deploy.rb file are loaded and then each capability has its
# 'defaults' task called.
#
# All capability's defaults tasks are in the format:
#   capabilities:defaults:<capability_name>
#
# Defaults tasks are there simply to set standard conventional
# standards on each capability.  In almost all cases, they can
# be overridden.
#
# Defaults are also optional.  If a capability doesn't require any
# environment variables to be set, it can simply omit a defaults task.
#
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'environment:defaults',       'capabilities:defaults'
  before  'capabilities:defaults',      'load_capabilities'

  namespace :capabilities do
    namespace :defaults do
      desc <<-DESC
        [internal] Installs all capabilities for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
      DESC
      task :default do
        defaults.send(deployment_type.to_s)

        if exists?(:capabilities)
          fetch(:capabilities).each do |capability|
            capabilities.defaults.send(capability.to_s) if capabilities.defaults.respond_to?(capability.to_sym)
          end
        end
      end
    end
  end
end

######################################################################
#                     DEFAULT CAPABILITIES SETUP                     #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'environment:defaults',       'capabilities:defaults:load'
  before  'capabilities:defaults:load', 'load_capabilities'

  namespace :capabilities do
    namespace :defaults do
      desc <<-DESC
        [internal] Installs the entire capabilities for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
      DESC
      task :load do
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

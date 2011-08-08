######################################################################
#                         CAPABILITIES CHECK                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before  'capabilities:variable:check',     'load_capability_checks'

  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc "[internal] Runs variable checks for all of the capabilities listed."
        task :default do
          if exists?(:capabilities)
            fetch(:capabilities).each do |capability|
              top.capabilities.variable.check.send(capability.to_s) if top.capabilities.variable.check.respond_to?(capability.to_sym)
            end
          end
        end
      end
    end

    namespace :deployment do
      namespace :check do
        desc "[internal] Runs deployment checks for all of the capabilities listed."
        task :default do
          if exists?(:capabilities)
            fetch(:capabilities).each do |capability|
              top.capabilities.deployment.check.send(capability.to_s) if top.capabilities.deployment.check.respond_to?(capability.to_sym)
            end
          end
        end
      end
    end
  end
end

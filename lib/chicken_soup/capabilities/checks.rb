######################################################################
#                         CAPABILITIES CHECK                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'environment:check',      'capabilities:check'
  before  'capabilities:check',     'load_capability_checks'

  namespace :capabilities do
    namespace :check do
      desc "[internal] Runs checks for all of the capabilities listed."
      task :default do
        if exists?(:capabilities)
          fetch(:capabilities).each do |capability|
            top.capabilities.check.send(capability.to_s) if top.capabilities.check.respond_to?(capability.to_sym)
          end
        end
      end
    end
  end
end

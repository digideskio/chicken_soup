######################################################################
#                         CAPABILITIES CHECK                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    desc "[internal] Runs checks for all of the capabilities listed."
    task :check do
      if exists?(:capabilities)
        fetch(:capabilities).each do |capability|
          top.capabilities.check.send(capability.to_s) if top.capabilities.check.respond_to?(capability.to_sym)
        end
      end
    end
  end
end

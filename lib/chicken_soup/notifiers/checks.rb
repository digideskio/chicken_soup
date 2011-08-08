######################################################################
#                           NOTIFIERS CHECK                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before  'notifiers:variable:check',         'load_notifier_checks'

  namespace :notifiers do
    namespace :variable do
      namespace :check do
        desc "[internal] Runs checks for all of the notifiers listed."
        task :default do
          if exists?(:notifiers)
            fetch(:notifiers).each do |notifier|
              top.notifiers.variable.check.send(notifier.to_s) if top.notifiers.variable.check.respond_to?(notifier.to_sym)
            end
          end
        end
      end
    end

    namespace :deployment do
      namespace :check do
        desc "[internal] Runs deployment checks for all of the notifiers listed."
        task :default do
          if exists?(:notifiers)
            fetch(:notifiers).each do |notifier|
              top.notifiers.deployment.check.send(notifier.to_s) if top.notifiers.deployment.check.respond_to?(notifier.to_sym)
            end
          end
        end
      end
    end
  end
end

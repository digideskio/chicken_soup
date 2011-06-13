######################################################################
#                           NOTIFIERS CHECK                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before  'notifiers:check',         'load_notifier_checks'

  namespace :notifiers do
    namespace :check do
      desc "[internal] Runs checks for all of the notifiers listed."
      task :default do
        if exists?(:notifiers)
          fetch(:notifiers).each do |notifier|
            top.notifiers.check.send(notifier.to_s) if top.notifiers.check.respond_to?(notifier.to_sym)
          end
        end
      end
    end
  end
end

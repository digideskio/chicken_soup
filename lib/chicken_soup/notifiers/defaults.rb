######################################################################
#                        DEFAULT NOTIFIERS SETUP                     #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'environment:defaults',       'notifiers:defaults:load'
  before  'notifiers:defaults:load',    'load_notifiers'

  namespace :notifiers do
    namespace :defaults do
      desc <<-DESC
        [internal] Installs the entire notifiers for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
      DESC
      task :load do
        if exists?(:notifiers)
          fetch(:notifiers).each do |notifier|
            notifiers.defaults.send(notifier.to_s) if notifiers.defaults.respond_to?(notifier.to_sym)
          end
        end
      end
    end
  end
end

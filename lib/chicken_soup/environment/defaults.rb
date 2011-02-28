######################################################################
#                      DEFAULT ENVIRONMENT SETUP                     #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'production',                           'environment:defaults:production', 'environment:defaults'
  after   'staging',                              'environment:defaults:staging', 'environment:defaults'

  before  'environment:defaults',                 'load_capabilities'

  namespace :environment do
    namespace :defaults do
      desc "[internal] Used to set up the intelligent staging defaults we like for our projects"
      task :staging do
        set :rails_env,             "staging"
      end

      desc "[internal] Used to set up the intelligent production defaults we like for our projects"
      task :production do
        set :rails_env,             "production"
      end

      desc "[internal] Sets intelligent common defaults for deployments"
      task :common do
        _cset :use_sudo,                  false
        _cset :default_shell,             false

        _cset :copy_compression,          :bz2

        _cset(:application_underscored)   {application.gsub(/-/, "_")}
      end

      desc "[internal] Sets defaults for all of the capabilities listed."
      task :capabilities do
        if exists?(:capabilities)
          fetch(:capabilities).each do |capability|
            environment.defaults.send(capability.to_s) if environment.defaults.respond_to?(capability.to_sym)
          end
        end
      end

      desc <<-DESC
        [internal] Installs the entire environment for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
      DESC
      task :default do
        defaults.common
        defaults.send(deployment_type.to_s)
        defaults.capabilities
      end
    end
  end
end

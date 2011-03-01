######################################################################
#                         ENVIRONMENT DEFAULTS                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'production',                 'environment:defaults:production', 'environment:defaults'
  after   'staging',                    'environment:defaults:staging',    'environment:defaults'

  namespace :environment do
    namespace :defaults do
      desc "[internal] Used to set up the intelligent staging defaults we like for our projects"
      task :staging do
        set :rails_env,                 'staging'
      end

      desc "[internal] Used to set up the intelligent production defaults we like for our projects"
      task :production do
        set :rails_env,                 'production'
      end

      desc "[internal] Sets intelligent common defaults for deployments"
      task :default do
        _cset :use_sudo,                  false
        _cset :default_shell,             false

        _cset :copy_compression,          :bz2

        _cset(:application_underscored)   {application.gsub(/-/, "_")}
      end
    end
  end
end

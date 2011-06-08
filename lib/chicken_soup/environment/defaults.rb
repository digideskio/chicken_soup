######################################################################
#                         ENVIRONMENT DEFAULTS
#
# This is where all of the environment defaults for the tasks are set.
#
# None of these defaults are specific to any of the capabilities we
# will add in later.
#
# The main tasks of note are the :staging and :production tasks.  Both
# of which will set the :rails_env variable so that the rest of the
# tasks know in what environment they are operating.
#
# Note: That these are the 'environment:defaults:staging' and
# 'environment:defaults:production' tasks and not the 'staging' and
# 'production' tasks.
#
# The latter should be set in the application's deploy.rb file.
#
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

        _cset :keep_releases,             15

        _cset :global_shared_files,       ["config/database.yml"]

        _cset(:application_short)         {application}
        _cset(:application_underscored)   {application.gsub(/-/, "_")}
      end
    end
  end
end

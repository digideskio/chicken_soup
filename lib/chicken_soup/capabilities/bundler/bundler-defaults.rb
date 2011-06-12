######################################################################
#                          BUNDLER DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Bundler deployments."
      task :bundler do
        _cset :gem_packager_version,  `gem list bundler`.match(/\((.*)\)/)[1]
        set   :rake,                  'bundle exec rake'
      end
    end
  end
end

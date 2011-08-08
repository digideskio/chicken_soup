######################################################################
#                          BUNDLER DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Bundler deployments."
      task :bundler do
        _cset :gem_packager_version,  `gem list bundler`.match(/\((.*)\)/)[1]
        _cset :gem_packager_gem_path, "#{shared_path}/bundle"

        set   :rake,                  "RAILS_ENV=#{rails_env} bundle exec rake"
      end
    end
  end
end

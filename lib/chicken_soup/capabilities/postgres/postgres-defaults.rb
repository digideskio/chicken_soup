######################################################################
#                          POSTGRES DEFAULTS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/shared/db-defaults'

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Postgres deployments."
      task :postgres do
        capabilities.defaults.db
      end
    end
  end
end

######################################################################
#                          POSTGRES CHECKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/shared/db-checks'

  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary Postgres capabilities variables have been set up.
        DESC
        task :postgres do
          capabilities.variable.check.db
        end
      end
    end
  end

  namespace :capabilities do
    namespace :deployment do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see Postgres is ready for deployment.
        DESC
        task :postgres do
          capabilities.deployment.check.db
        end
      end
    end
  end
end

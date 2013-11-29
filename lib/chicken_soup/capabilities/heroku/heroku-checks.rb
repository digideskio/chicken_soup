######################################################################
#                           HEROKU CHECKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary Heroku environment variables have been set up.
        DESC
        task :heroku do
          required_variables = [
            :deploy_site_name,
          ]

          verify_variables(required_variables)
        end
      end
    end
  end
end

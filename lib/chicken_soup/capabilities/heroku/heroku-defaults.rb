######################################################################
#                           HEROKU DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Heroku deployments"
      task :heroku do
      end
    end
  end
end

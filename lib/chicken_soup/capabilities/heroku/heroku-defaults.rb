######################################################################
#                           HEROKU DEFAULTS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for Heroku deployments"
      task :heroku do
        _cset :heroku_credentials_path,   "#{ENV["HOME"]}/.heroku"
        _cset :heroku_credentials_file,   "#{heroku_credentials_path}/credentials"

        _cset(:password)                  {Capistrano::CLI.password_prompt("Encrypted Heroku Password: ")}
      end
    end
  end
end

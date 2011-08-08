######################################################################
#                       PASSENGER DEFAULTS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      set :application_server_type,   :passenger
    end
  end
end

######################################################################
#                       PASSENGER DEFAULTS                           #
######################################################################
module ChickenSoup
  module ApplicationServer
    STANDARD_LOGS = ['passenger_log', 'passenger.log', 'passenger']
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      set :application_server_type,   :passenger
    end
  end
end

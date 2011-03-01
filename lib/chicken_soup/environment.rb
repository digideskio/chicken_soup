######################################################################
#                          ENVIRONMENT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/environment/setup'
  require 'chicken_soup/environment/defaults'
end

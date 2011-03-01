######################################################################
#                          ENVIRONMENT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/environment/defaults'
  require 'chicken_soup/environment/checks'
end

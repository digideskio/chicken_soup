######################################################################
#                          POSTGRES TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/shared/db'
end

######################################################################
#                       HOPTOAD NOTIFIER TASKS                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after "deploy",            "notify:via_airbrake"

end

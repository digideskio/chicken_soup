######################################################################
#                         CAPABILITIES TASKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  after   'load_capability_checks', 'load_capability_tasks'
end

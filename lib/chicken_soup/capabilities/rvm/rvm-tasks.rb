######################################################################
#                             RVM TASKS                              #
######################################################################
def run_with_rvm(ruby_env_string, command)
  run("rvm use #{ruby_env_string} && #{command}")
end

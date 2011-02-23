######################################################################
#                             RVM TASKS                              #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  _cset :ruby_version,        ENV["rvm_ruby_string"]
  _cset :ruby_gemset,         ENV["GEM_HOME"].split('@')[1]

  _cset(:rvm_ruby_string)     {ruby_gemset ? "#{ruby_version}@#{ruby_gemset}" : ruby_version}
end

def run_with_rvm(ruby_env_string, command)
  run("rvm use #{ruby_env_string} && #{command}")
end

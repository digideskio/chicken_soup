######################################################################
#                             RVM TASKS                              #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  set :ruby_version,          ENV["rvm_ruby_string"]                      unless exists?(:ruby_version)
  set :ruby_gemset,           ENV["GEM_HOME"].split('@')[1]               unless exists?(:ruby_gemset)

  set(:rvm_ruby_string)       {ruby_gemset ? "#{ruby_version}@#{ruby_gemset}" : ruby_version}          unless exists?(:rvm_ruby_string)
end

def run_with_rvm(ruby_env_string, command)
  run("rvm use #{ruby_env_string} && #{command}")
end

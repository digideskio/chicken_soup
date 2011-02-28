######################################################################
#                             RVM TASKS                              #
######################################################################
def run_with_rvm(ruby_env_string, command)
  run("rvm use #{ruby_env_string} && #{command}")
end

######################################################################
#                       RVM ENVIRONMENT CHECKS                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :check do
      desc <<-DESC
        [internal] Checks to see if all necessary RVM variables have been set up.
      DESC
      task :rvm do
        required_variables = [
          :ruby_version,
          :ruby_gemset,
          :rvm_ruby_string,
        ]

        verify_variables(required_variables)
      end
    end
  end
end

######################################################################
#                    DEFAULT RVM ENVIRONMENT SETUP                   #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :defaults do
      _cset :ruby_version,        ENV["rvm_ruby_string"]
      _cset :ruby_gemset,         ENV["GEM_HOME"].split('@')[1]

      _cset(:rvm_ruby_string)     {ruby_gemset ? "#{ruby_version}@#{ruby_gemset}" : ruby_version}
    end
  end
end

######################################################################
#                             RVM CHECKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
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

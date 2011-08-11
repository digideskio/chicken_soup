######################################################################
#                             GIT CHECKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary Git variables have been set up.
        DESC
        task :rvm do
          required_variables = [
            :repository
          ]

          verify_variables(required_variables)
        end
      end
    end
  end
end

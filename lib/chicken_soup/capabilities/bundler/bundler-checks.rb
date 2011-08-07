######################################################################
#                           BUNDLER CHECKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary Bundler capabilities variables have been set up.
        DESC
        task :bundler do
          required_variables = [
            :gem_packager_version
          ]

          verify_variables(required_variables)
        end
      end
    end
  end
end

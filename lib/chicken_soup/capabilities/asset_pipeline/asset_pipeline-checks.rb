######################################################################
#                     ASSET PIPELINE DEFAULTS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary asset pipeline capabilities variables have been set up.
        DESC
        task :asset_pipeline do
          required_variables = [
            :assets_path
          ]

          verify_variables(required_variables)
        end
      end
    end
  end
end

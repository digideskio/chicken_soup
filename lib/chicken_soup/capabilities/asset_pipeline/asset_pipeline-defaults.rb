######################################################################
#                     ASSET PIPELINE DEFAULTS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent defaults for the asset pipeline."
      task :asset_pipeline do
        _cset :assets_path,       "#{shared_path}/assets"
      end
    end
  end
end

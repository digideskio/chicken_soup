######################################################################
#                     ASSET PIPELINE DEFAULTS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before    'deploy:cleanup',     'assets:update'

  namespace :assets do
    desc 'Recompile all of the assets in the project.'
    task :precompile, :roles => :app do
      asset_pipeline.precompile
    end

    desc 'Removes all of the assets currently compiled.'
    task :clean, :roles => :app do
      run "rm -rf #{assets_path}/*"
    end

    desc 'Symlinks the shared asset directory to the current release'
    task :symlink, :roles => :app do
      run "ln -nsf #{assets_path} #{latest_release}/public/assets"
    end

    desc 'Remove and recompile all of the assets in the project.'
    task :update, :roles => :app do
      assets.symlink
      assets.clean
      assets.precompile
    end
  end

  namespace :asset_pipeline do
    task :precompile, :roles => :app do
      run "cd #{current_path} && #{rake} RAILS_GROUPS=assets assets:precompile"
    end
  end
end

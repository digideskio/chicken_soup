######################################################################
#                           BUNDLER TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  set :gem_packager_version,  `gem list bundler`.match(/\((.*)\)/)[1]     unless exists?(:gem_packager_version)
  set :rake,                  'bundle exec rake'

  before 'gems:install',      'bundler:install'

  namespace :gems do
    desc "Install Bundled Gems"
    task :install do
      run "cd #{current_release} && bundle install --gemfile #{current_release}/Gemfile --path #{shared_path}/bundle --deployment --quiet --without development test"
    end

    desc "Update Bundled Gems"
    task :update do
      raise "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'

      run "cd #{current_release} && bundle update"
    end
  end

  namespace :bundler do
    desc "Install Bundler"
    task :install do
      run_with_rvm "#{ruby_version}@global", "gem install bundler --version #{gem_packager_version} --no-ri --no-rdoc && gem cleanup bundler"
    end
  end
end

######################################################################
#                           BUNDLER TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before    'gems:install',       'bundler:install'

  run_task  'bundler:install',    :as => manager_username

  namespace :gems do
    desc "Install Bundled Gems"
    task :install, :roles => :app do

      run "cd #{latest_release} && bundle install --gemfile #{latest_release}/Gemfile --path #{shared_path}/bundle --deployment --without development test"
    end

    desc "Update Bundled Gems"
    task :update, :roles => :app do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'

      run "cd #{latest_release} && bundle update"
    end
  end

  namespace :bundler do
    desc "Install Bundler"
    task :install, :roles => :app do
      bundler_install_command = "gem install bundler --version #{gem_packager_version} --no-ri --no-rdoc && gem cleanup bundler"

      if fetch(:capabilities).include? :rvm
        run_with_rvm "#{ruby_version}@global", bundler_install_command
      else
        run bundler_install_command
      end
    end
  end
end

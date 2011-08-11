######################################################################
#                           BUNDLER TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  before    'gems:install',       'bundler:install'

  run_task  'bundler:install',    :as => manager_username

  namespace :gems do
    desc "Processes the file containing all of the gems that you want installed and installs them one-by-one."
    task :install, :roles => :app do
      run_with_ruby_manager full_ruby_environment_string, "bundle install --gemfile #{latest_release}/Gemfile --path #{gem_packager_gem_path} --deployment --without development test"
    end

    desc <<-DESC
      Checks for the newest version of each gem and installs it.

      > Note: This can never be used in production.  If you really wish to do this,
      > you'll need to log into the server manually or use Capistrano's `console` task.
    DESC
    task :update, :roles => :app do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'

      run "cd #{latest_release} && bundle update"
    end

    desc "Removes all of the gems currently installed."
    task :clean, :roles => :app do
      run "rm -rf #{gem_packager_gem_path}/*"
    end
  end

  namespace :bundler do
    desc "Install Bundler"
    task :install, :roles => :app do
      bundler_install_command = "gem install bundler --version #{gem_packager_version} --no-ri --no-rdoc && gem cleanup bundler"

      run_with_ruby_manager "#{ruby_version}@global", bundler_install_command
    end
  end
end

######################################################################
#                            HEROKU TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  heroku_tasks = [
    "deploy",
    "deploy:default",
    "deploy:initial",
    "deploy:restart",
    "deploy:migrate",
    "deploy:rollback",
    "deploy:rollback:default",
    "deploy:web:enable",
    "deploy:web:disable",
    "website:install",
    "website:remove",
    "db:drop",
    "db:backup",
    "db:reset_and_seed",
    "db:seed",
    "shell",
    "invoke"
  ]

  on :start, "heroku:credentials", :only => heroku_tasks
  on :start, "heroku:raise_error", :except => heroku_tasks

  namespace :heroku do
    namespace :domain do
      desc <<-DESC
        Installs a new domain for the application on the Heroku server.
      DESC
      task :install do
        `heroku domains:add #{deploy_site_name}`
      end

      desc <<-DESC
        Removes the domain for the application from the Heroku server.
      DESC
      task :remove do
        `heroku domains:remove #{deploy_site_name}`
      end

      namespace :addon do
        desc <<-DESC
          Add the Custom Domain Addon to the server.
        DESC
        task :install do
          `heroku addons:add custom_domains:basic`
        end

        desc <<-DESC
          Removes the Custom Domain Addon from the server.
        DESC
        task :remove do
          `heroku addons:remove custom_domains:basic`
        end
      end
    end

    namespace :credentials do
      desc <<-DESC
        Selects the correct Heroku credentials for use given the current user.

        If a credentials file already exists, it is backed up.
      DESC
      task :default do
        if File.exist? heroku_credentials_file
          heroku.credentials.backup
        end

        if File.exist? "#{heroku_credentials_path}/#{user}_credentials"
          heroku.credentials.switch
        else
          heroku.credentials.create
        end
      end

      desc <<-DESC
        [internal] Backs up the current credentials file.
      DESC
      task :backup do
        account = File.readlines(heroku_credentials_file)[0].chomp
        File.rename(heroku_credentials_file, "#{heroku_credentials_path}/#{account}_credentials")
      end

      desc <<-DESC
        [internal] Creates a Heroku credentials file.
      DESC
      task :create do
        `if [ ! -d #{heroku_credentials_path} ]; then mkdir -p #{heroku_credentials_path}; fi`
        `echo #{user} > #{heroku_credentials_file}`
        `echo #{password} >> #{heroku_credentials_file}`
      end

      desc <<-DESC
        [internal] Switches the credentials file to either the current use or the
        name specified by the `HEROKU_ACCOUNT` environment variable.
      DESC
      task :switch do
        account_to_switch_to = ENV['HEROKU_ACCOUNT'] || user
        File.rename("#{heroku_credentials_path}/#{account_to_switch_to}_credentials", heroku_credentials_file)
      end
    end

    desc <<-DESC
      [internal] Raises an error if someone tries to run a task other than those
      that are valid for a Heroku deployment.
    DESC
    task :raise_error do
      abort "Deploying the #{rails_env} environment to Heroku.  This command is invalid."
    end
  end

  namespace :deploy do
    desc <<-DESC
      The standard deployment task.

      It will check out a new release of the code, run any pending migrations and
      restart the application.
    DESC
    task :default do
      `git push heroku #{branch}`
      deploy.migrate
      deploy.restart
    end

    desc <<-DESC
      Restarts the application.
    DESC
    task :restart do
      `heroku restart`
    end

    desc <<-DESC
      Runs the migrate rake task.
    DESC
    task :migrate do
      `heroku rake db:migrate`
    end

    desc <<-DESC
      Rolls back to a previous version and restarts.
    DESC
    namespace :rollback do
      task :default do
        `heroku rollback`
        deploy.restart
      end
    end

    namespace :web do
      desc "Removes the maintenance page to resume normal site operation."
      task :enable do
        `heroku maintenance:off`
      end

      desc "Diplays the maintenance page."
      task :disable do
        `heroku maintenance:on`
      end
    end

    desc "Prepare the server for deployment."
    task :initial do
      website.install

      heroku.domain.addon.install
      db.backup.addon.install

      heroku.domain.install

      `heroku config:add BUNDLE_WITHOUT="development:test"`
      deploy.default
    end
  end

  namespace :website do
    desc "Installs the application on Heroku"
    task :install do
      `heroku create #{application}`
    end

    desc "Completely removes application from Heroku"
    task :remove do
      `heroku destroy --confirm #{application}`
    end
  end

  namespace :db do
    desc "Removes the DB from the Server.  Also removes the user."
    task :drop do
      `heroku pg:reset`
    end

    namespace :backup do
      desc "Backup the database"
      task :default do
        `heroku pgbackups:capture`
      end

      namespace :addon do
        desc <<-DESC
          Add the Postgres Backups Addon to the server.
        DESC
        task :install do
          `heroku addons:add pgbackups:basic`
        end

        desc <<-DESC
          Removes the Postgres Backups Addon from the server.
        DESC
        task :remove do
          `heroku addons:remove pgbackups:basic`
        end
      end
    end

    desc "Reset database and seed fresh"
    task :reset_and_seed do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      `heroku pg:reset`
      `heroku rake db:seed`
    end

    desc "Seed database"
    task :seed do
      abort "I'm sorry Dave, but I can't let you do that. I have full control over production." if rails_env == 'production'
      db.backup
      `heroku rake db:seed`
    end
  end

  desc "Begin an interactive Heroku session."
  task :shell do
    `heroku shell`
  end

  desc "Invoke a single command on the Heroku server."
  task :invoke do
    `heroku invoke #{ENV['COMMAND']}`
  end
end

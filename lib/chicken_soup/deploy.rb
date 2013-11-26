######################################################################
#                           DEPLOYMENT TASKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    desc <<-DESC
      [internal] The list of tasks used by `deploy`, `deploy:cold`, `deploy:subzero` and `deploy:initial`
    DESC
    task :base do
      transaction do
        send(deployment_type).deploy.base
      end
    end

    desc <<-DESC
      Used when you would like to be more forceful with your deployment.

      It will forceably disable the site (from the web server layer), run a standard
      deployment and re-enable the site.
    DESC
    task :cold do
      transaction do
        send(deployment_type).deploy.base
      end
    end

    desc <<-DESC
      When you just want to "FINISH HIM!", hit "Forward, Down, Forward, High Punch" \
      and your website will be at your mercy.

      It will forceably stop the web server, run a standard deployment, and restart \
      the web server.
    DESC
    task :subzero do
      transaction do
        send(deployment_type).deploy.subzero
      end
    end

    desc <<-DESC
      This task should be used only on the first deployment.

      It will set up the deployment structure that Capistrano uses, create the DB, install
      the website configuration files into the web server, and then run a standard "cold"
      deployment.
    DESC
    task :initial do
      transaction do
        send(deployment_type).deploy.initial
      end
    end

    desc <<-DESC
      The standard deployment task.

      It will check out a new release of the code to the `releases` directory, update the
      symlinks to the desired shared configuration files, install all necessary gems,
      run all pending migrations, tag the git commit, perform a cleanup and restart
      the application layer so that the changes will take effect.
    DESC
    task :default do
      transaction do
        send(deployment_type).deploy.default
      end
    end
  end
end

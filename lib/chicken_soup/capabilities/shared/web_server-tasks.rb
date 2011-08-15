######################################################################
#                    COMMON WEB SERVER TASKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  run_task  'web_server:stop',            :as => manager_username
  run_task  'web_server:start',           :as => manager_username
  run_task  'web_server:restart',         :as => manager_username
  run_task  'web_server:reload',          :as => manager_username

  run_task  'website:install',            :as => manager_username
  run_task  'website:remove',             :as => manager_username
  run_task  'website:enable',             :as => manager_username
  run_task  'website:disable',            :as => manager_username

  before    'deploy',                     'deploy:web:disable'
  after     'deploy',                     'deploy:web:enable'

  before    'deploy:subzero',             'web_server:stop'
  after     'deploy:subzero',             'web_server:start'

  before    'deploy:cold',                'website:disable'
  after     'deploy:cold',                'website:enable'

  namespace :deploy do
    namespace :web do
      desc <<-DESC
        Enables the website's application by removing the maintenance page.
      DESC
      task :enable, :roles => :web do
        website.maintenance_mode.disable
      end

      desc <<-DESC
        Disables the website's application by installing the maintenance page.
      DESC
      task :disable, :roles => :web do
        website.maintenance_mode.enable
      end
    end
  end

  namespace :website do
    namespace :maintenance_mode do
      desc <<-DESC
        Makes the application web-accessible again. Removes the \
        "maintenance.html" page generated by deploy:web:disable, which (if your \
        web servers are configured correctly) will make your application \
        web-accessible again.
      DESC
      task :disable, :roles => :web do
        run "rm #{shared_path}/system/#{maintenance_basename}.html"
      end

      desc <<-DESC
        Present a maintenance page to visitors. Disables your application's web \
        interface by writing a "maintenance.html" file to each web server. The \
        servers must be configured to detect the presence of this file, and if \
        it is present, always display it instead of performing the request.

        By default, the maintenance page will just say the site is down for \
        "maintenance", and will be back "shortly", but you can customize the \
        page by specifying the REASON and UNTIL environment variables:

          $ cap deploy:web:disable \\
                REASON="hardware upgrade" \\
                UNTIL="12pm Central Time"

        Further customization will require that you write your own task.
      DESC
      task :enable, :roles => :web do
        on_rollback { rm "#{shared_path}/system/#{maintenance_basename}.html" }

        require 'erb'
        deadline, reason = ENV['UNTIL'], ENV['REASON']

        template = File.read("./public/maintenance.html.erb")
        maintenance_page = ERB.new(template).result(binding)

        put maintenance_page, "#{shared_path}/system/#{maintenance_basename}.html", :mode => 0644
      end
    end
  end

  namespace :web_server do
    desc "Stop the web server"
    task :stop, :roles => :web do
      run "#{sudo} #{web_server_control_script} stop", :pty => true
    end

    desc "Start the web server"
    task :start, :roles => :web do
      run "#{sudo} #{web_server_control_script} start", :pty => true
    end

    desc "Restart the web server"
    task :restart, :roles => :web do
      run "#{sudo} #{web_server_control_script} restart", :pty => true
    end

    desc "Reloads the web server configuration"
    task :reload, :roles => :web do
      run "#{sudo} #{web_server_control_script} reload", :pty => true
    end
  end
end

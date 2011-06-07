######################################################################
#                            APACHE TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  on        :start,                       'apache:environment_detection'

  run_task  'web_server:stop',            :as => :manager_username
  run_task  'web_server:start',           :as => :manager_username
  run_task  'web_server:restart',         :as => :manager_username

  run_task  'website:install',            :as => :manager_username
  run_task  'website:remove',             :as => :manager_username
  run_task  'website:enable',             :as => :manager_username
  run_task  'website:disable',            :as => :manager_username

  namespace :deploy do
    namespace :web do
      desc <<-DESC
        Enables the website's application by removing the maintenance page.
      DESC
      task :enable do
        website.maintenance_mode.disable
      end

      desc <<-DESC
        Disables the website's application by installing the maintenance page.
      DESC
      task :disable do
        website.maintenance_mode.enable
      end
    end
  end

  namespace :web_server do
    desc "Stop Apache"
    task :stop do
      apache.stop
    end

    desc "Start Apache"
    task :start do
      apache.start
    end

    desc "Restart Apache"
    task :restart do
      apache.restart
    end
  end

  namespace :website do
    desc "Creates the site configuration for the files."
    task :create do
      apache.virtual_host.install
    end

    desc "Completely removes the site configuration from the server (but leaves the files.)"
    task :remove do
      apache.virtual_host.remove
    end

    desc "Enable Site"
    task :enable do
      apache.website.enable
    end

    desc "Disable Site"
    task :disable do
      apache.website.disable
    end

    namespace :maintenance_mode do
      desc <<-DESC
        Makes the application web-accessible again. Removes the \
        "maintenance.html" page generated by deploy:web:disable, which (if your \
        web servers are configured correctly) will make your application \
        web-accessible again.
      DESC
      task :disable, :except => { :no_release => true } do
        run "rm #{shared_path}/system/maintenance.html"
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
      task :enable, :except => { :no_release => true } do
        on_rollback { rm "#{shared_path}/system/maintenance.html" }

        require 'erb'
        deadline, reason = ENV['UNTIL'], ENV['REASON']

        template = File.read("./app/views/layouts/maintenance.html.erb")
        maintenance_page = ERB.new(template).result(binding)

        put maintenance_page, "#{shared_path}/system/maintenance.html", :mode => 0644
      end
    end
  end

  namespace :apache do
    desc "[internal] Checks to see what type of Apache installation is running on the remote."
    task :environment_detection do
      find_apache_control_script

      if apache_control_script =~ /apache2/
        set :apache_enable_script,    "a2ensite"
        set :apache_disable_script,   "a2dissite"
      end
    end

    desc "[internal] Starts the Apache webserver"
    task :start do
      run "#{sudo} #{apache_control_script} start"
    end

    desc "[internal] Stops the Apache webserver"
    task :stop do
      run "#{sudo} #{apache_control_script} stop"
    end

    desc "[internal] Stops the Apache webserver"
    task :restart do
      run "#{sudo} #{apache_control_script} restart"
    end

    desc "[internal] Reloads the Apache configurations."
    task :reload do
      run "#{sudo} #{apache_control_script} reload"
    end

    namespace :website do
      desc "[internal] Enables the Apache site on the server level."
      task :enable do
        abort "Sorry, auto-enabling sites is not supported on your version of Apache." unless exists?(:apache_enable_script)

        run "#{sudo} #{apache_enable_script} #{deploy_name}"
        apache.reload
      end

      desc "[internal] Disables the Apache site on the server level."
      task :disable do
        abort "Sorry, auto-disabling sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

        run "#{sudo} #{apache_disable_script} #{deploy_name}"
        apache.reload
      end
    end

    namespace :virtual_host do
      desc "[internal] Install Virtual Host"
      task :install do
        abort "Sorry, auto-installing sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

        virtual_host_config = <<-VHOST
          <VirtualHost #{web_server_ip}:443>
            ServerName #{deploy_name}
            DocumentRoot #{deploy_to}/current/public

            SSLEngine on
            SSLCertificateFile       /etc/ssl/certs/#{domain}.crt
            SSLCertificateKeyFile    /etc/ssl/certs/#{domain}.key

            RailsEnv #{rails_env}
            RackEnv #{rails_env}

            <Directory "#{deploy_to}/current/public">
              Options FollowSymLinks -MultiViews
              AllowOverride all
              Order allow,deny
              Allow from all
            </Directory>

            RewriteEngine On

            ErrorDocument 503 /system/maintenance.html
            RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
            RewriteCond %{SCRIPT_FILENAME} !maintenance.html
            RewriteCond %{REQUEST_URI} !^/images/
            RewriteCond %{REQUEST_URI} !^/robots.txt
            RewriteCond %{REQUEST_URI} !^/sitemap
            RewriteRule ^.*$ - [redirect=503,last]

            ErrorLog /var/log/apache2/#{application}-errors.log

            LogLevel warn

            CustomLog /var/log/apache2/#{application}-access.log combined
            ServerSignature On
          </VirtualHost>

          <VirtualHost #{web_server_ip}:80>
            ServerName #{deploy_name}

            Redirect   permanent / https://#{deploy_name}
          </VirtualHost>
        VHOST

        put virtual_host_config, "#{user_home}/#{deploy_name}"
        run "#{sudo} mv #{user_home}/#{deploy_name} /etc/apache2/sites-available"
        run "#{sudo} /etc/init.d/apache2 reload"
      end

      desc "[internal] Remove Virtual Host"
      task :remove do
        abort "Sorry, auto-removing sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

        run "#{sudo} rm /etc/apache2/sites-available/#{deploy_name}"
        run "#{sudo} /etc/init.d/apache2 reload"
      end
    end
  end
end

def find_apache_control_script
  if remote_file_exists?("/usr/sbin/apachectl")
    set :apache_control_script,   "/usr/sbin/apachectl"
  elsif remote_file_exists?("/usr/sbin/apache2")
    set :apache_control_script,   "/usr/sbin/apache2"
  end

  abort "Couldn't figure out your version of Apache" unless exists?(:apache_control_script)
end

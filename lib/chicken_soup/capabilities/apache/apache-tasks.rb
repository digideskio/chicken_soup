######################################################################
#                            APACHE TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require   'chicken_soup/capabilities/shared/web_server-tasks'

  namespace :website do
    desc "Creates the site configuration for the files."
    task :create do
      abort "Sorry, auto-installing sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

      virtual_host_config = <<-VHOST
        <VirtualHost #{web_server_ip}:443>
          ServerName #{deploy_site_name}
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
          ServerName #{deploy_site_name}

          Redirect   permanent / https://#{deploy_site_name}
        </VirtualHost>
      VHOST

      put virtual_host_config, "#{user_home}/#{deploy_site_name}"
      run "#{sudo} mv #{user_home}/#{deploy_site_name} /etc/apache2/sites-available"
      web_server.reload
    end

    desc "Completely removes the site configuration from the server (but leaves the files.)"
    task :remove do
      abort "Sorry, auto-removing sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

      run "#{sudo} rm /etc/apache2/sites-available/#{deploy_site_name}"
      web_server.reload
    end

    desc "Enable Site"
    task :enable do
      abort "Sorry, auto-enabling sites is not supported on your version of Apache." unless exists?(:apache_enable_script)

      run "#{sudo} #{apache_enable_script} #{deploy_site_name}"
      web_server.reload
    end

    desc "Disable Site"
    task :disable do
      abort "Sorry, auto-disabling sites is not supported on your version of Apache." unless exists?(:apache_disable_script)

      run "#{sudo} #{apache_disable_script} #{deploy_site_name}"
      web_server.reload
    end
  end
end

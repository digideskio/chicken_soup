######################################################################
#                             NGINX TASKS                            #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require   'chicken_soup/capabilities/shared/web_server-tasks'

  namespace :website do
    desc "Creates the site configuration for the files."
    task :create, :roles => :web do
      abort "Sorry, auto-installing sites is not supported on your installation of Nginx." unless exists?(:nginx_disable_script)

      passenger_friendly_error_pages = rails_env == :production ? "off" : "on"

      virtual_host_config = <<-VHOST
        server {
          ###
          # Server Details
          #
            listen                          #{web_server_ip}:443;
            server_name                     .#{deploy_site_name};

            root                            #{deploy_to}/current/public;

          ###
          # Passenger and Rails
          #
            passenger_enabled               on;
            passenger_friendly_error_pages  #{passenger_friendly_error_pages};
            passenger_min_instances         4;

            rails_env                       #{rails_env};
            rack_env                        #{rails_env};

          ###
          # Performance and Security
          #
            client_max_body_size            3M;

            location ~ /\. { deny  all; }       # This will deny access to any hidden file (beginning with a period)

          ###
          # SSL
          #
            ssl                             on;
            ssl_certificate                 /etc/nginx/ssl/#{domain}.crt;
            ssl_certificate_key             /etc/nginx/ssl/#{domain}.key;

            ssl_session_timeout             5m;

            ssl_protocols                   SSLv3 TLSv1;
            ssl_ciphers                     ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
            ssl_prefer_server_ciphers       on;

          ###
          # Logs
          #
            access_log                      /var/log/nginx/#{application}.access.log main;
            error_log                       /var/log/nginx/#{application}.error.log warn;

          ###
          # Handle Errors
          #
            recursive_error_pages           on;

            error_page                      500 502 504 /500.html;
            error_page                      400 /404.html;
            error_page                      422 /422.html;
            error_page                      503 @503;

            if (-f $document_root/system/maintenance.html) {
              return 503;
            }

            location @503 {
              error_page 405 = $document_root/system/maintenance.html;

              rewrite ^(.*)$ /system/maintenance.html break;
            }
        }

        server {
            listen                          #{web_server_ip}:80;
            server_name                     .#{deploy_site_name};

            rewrite ^ https://$http_host$request_uri? permanent
        }
      VHOST

      put virtual_host_config, "#{user_home}/#{deploy_site_name}"
      run "#{sudo} mv #{user_home}/#{deploy_site_name} /etc/nginx/sites-available"
      web_server.reload
    end

    desc "Completely removes the site configuration from the server (but leaves the files.)"
    task :remove, :roles => :web do
      abort "Sorry, auto-removing sites is not supported on your installation of Nginx." unless exists?(:nginx_disable_script)

      run "#{sudo} rm /etc/nginx/sites-available/#{deploy_site_name}"
      web_server.reload
    end

    desc "Enable Site"
    task :enable, :roles => :web do
      abort "Sorry, auto-enabling sites is not supported on your installation of Nginx." unless exists?(:nginx_enable_script)
    end

    desc "Disable Site"
    task :disable, :roles => :web do
      abort "Sorry, auto-disabling sites is not supported on your installation of Nginx." unless exists?(:nginx_disable_script)
    end
  end
end

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
            listen                          #{web_server_ip}:443;
            server_name                     #{deploy_site_name} *.#{deploy_site_name};

            passenger_enabled               on;
            passenger_friendly_error_pages  #{passenger_friendly_error_pages};
            passenger_min_instances         4;

            rails_env                       #{rails_env};
            rack_env                        #{rails_env};

            ssl                             on;
            ssl_certificate                 /etc/nginx/ssl/#{domain}.crt;
            ssl_certificate_key             /etc/nginx/ssl/#{domain}.key;

            ssl_session_timeout             5m;

            ssl_ciphers                     ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
            ssl_prefer_server_ciphers       on;

            root                            #{deploy_to}/current/public;

            client_max_body_size            3M;

            access_log                      /var/log/nginx/#{application}.access.log main;
            error_log                       /var/log/nginx/#{application}.error.log warn;

            error_page                      500 501 504 505 506 507 508 509 /500.html;
            error_page                      400 401 403 404 405 406 407 409 410 413 415 416 417 /404.html;
            error_page                      422 444 /422.html;
            error_page                      502 503 /public/maintenance.html;

            location / {
              try_files /system/maintenance.html $request_uri;
            }
        }

        server {
            listen                          #{web_server_ip}:80;
            server_name                     #{deploy_site_name} *.#{deploy_site_name};

            location / {
              rewrite ^ https://$http_host$request_uri? permanent
            }
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

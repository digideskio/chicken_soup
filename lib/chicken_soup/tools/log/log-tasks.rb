######################################################################
#                            LOG TASKS                               #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :log do
    desc <<-DESC
      Begins tailing the Rails log file within the specified environment.

      * Pass lines=<number> to give you a bigger look back at what has
        recently happened.  ie: cap staging log lines=50
    DESC
    task :default, :roles => :app do
      log.all.tail
    end

    namespace :application do
      task :fetch, :roles => :app do
        fetch_logs(rails_log_files)
      end

      task :tail, :roles => :app do
        tail_logs(rails_log_files)
      end
    end

    namespace :app_server do
      task :fetch, :roles => :app do
        fetch_logs(app_server_log_files)
      end

      task :tail, :roles => :app do
        tail_logs(app_server_log_files)
      end
    end

    namespace :web_server do
      task :fetch, :roles => :web do
        fetch_logs(web_server_log_files)
      end

      task :tail, :roles => :web do
        tail_logs(web_server_log_files)
      end
    end

    namespace :all do
      task :fetch, :roles => [:app, :web] do
        fetch_logs(log_files)
      end

      task :tail, :roles => [:app, :web] do
        tail_logs(log_files)
      end
    end
  end
end

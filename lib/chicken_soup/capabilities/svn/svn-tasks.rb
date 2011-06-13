######################################################################
#                          SUBVERSION TASKS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :vc do
    desc <<-DESC
    DESC
    task :log do
      set :vc_log, `svn log -r #{previous_revision.to_i + 1}:#{current_revision}`
    end
  end
end

######################################################################
#                              GIT TASKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :vc do
    desc <<-DESC
    DESC
    task :log do
      set :vc_log, `git log #{previous_revision}..#{current_revision} --pretty=format:%ai:::%an:::%s`
    end
  end
end

######################################################################
#                             GIT DEFAULTS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent version control defaults for deployments"
      task :git do
        _cset :deploy_via,                :remote_cache

        set :scm,                         :git
        set(:branch)                      { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        set(:remote)                      { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }

        ssh_options[:forward_agent]       = true
      end
    end
  end
end

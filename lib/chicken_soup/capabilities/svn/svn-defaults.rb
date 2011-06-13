######################################################################
#                         SUBVERSION DEFAULTS                        #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets intelligent version control defaults for deployments"
      task :svn do
        set :scm,                         :subversion

        # _cset :github_account,            ENV["USER"]
        # _cset :deploy_via,                :remote_cache
        # _cset(:repository)                {"git@github.com:#{github_account}/#{application}.git"}
        # _cset(:branch)                    { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        # _cset(:remote)                    { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }

        # ssh_options[:forward_agent]       = true
      end
    end
  end
end

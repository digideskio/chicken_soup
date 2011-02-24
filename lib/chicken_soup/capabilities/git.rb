######################################################################
#                              GIT TASKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  # before  'deploy:cleanup',           'deploy:tag'

  namespace :deploy do
    desc <<-DESC
      Tags the deployed Git commit with the timestamp and environment it was deployed to.

      The tag is auto-pushed to whatever `remote` is set to as well as `origin`.
      Tag push happens in the background so it won't slow down deployment.
    DESC
    task :tag do
      timestamp_string_without_seconds = Time.now.strftime("%Y%m%d%H%M")
      tag_name = "deployed_to_#{rails_env}_#{timestamp_string_without_seconds}"

      `git tag -a -m "Tagging deploy to #{rails_env} at #{timestamp_string_without_seconds}" #{tag_name} #{branch}`
      `git push #{remote} --tags > /dev/null 2>&1 &`
      `git push origin --tags > /dev/null 2>&1 &`
    end
  end
end

######################################################################
#                        GIT ENVIRONMENT CHECK                       #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :defaults do
      desc "[internal] Sets intelligent version control defaults for deployments"
      task :git do
        _cset :github_account,            ENV["USER"]
        _cset :deploy_via,                :remote_cache

        set :scm,                         :git
        set(:repository)                  {"git@github.com:#{github_account}/#{application}.git"}
        set(:branch)                      { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        set(:remote)                      { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }
        ssh_options[:forward_agent]       = true
      end
    end
  end
end

######################################################################
#                          DEFAULT GIT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :environment do
    namespace :defaults do
      desc "[internal] Sets intelligent version control defaults for deployments"
      task :git do
        _cset :github_account,            ENV["USER"]
        _cset :deploy_via,                :remote_cache

        set :scm,                         :git
        set(:repository)                  {"git@github.com:#{github_account}/#{application}.git"}
        set(:branch)                      { `git branch`.match(/\* (\S+)\s/m)[1] || raise("Couldn't determine current branch") }
        set(:remote)                      { `git remote`.match(/(\S+)\s/m)[1] || raise("Couldn't determine default remote repository") }
        ssh_options[:forward_agent]       = true
      end
    end
  end
end

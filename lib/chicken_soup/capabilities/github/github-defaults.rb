######################################################################
#                          GITHUB DEFAULTS                           #
######################################################################
require   'chicken_soup/capabilities/git/git-defaults'

Capistrano::Configuration.instance(:must_exist).load do
  before    'capabilities:defaults:github',     'capabilities:defaults:git'

  namespace :capabilities do
    namespace :defaults do
      desc "[internal] Sets defaults for deployments from Github"
      task :github do
        _cset :github_account,            local_user
        _cset :github_repository,         application

        set :github_url,                  "https://github.com/#{github_account}/#{github_repository}/tree/#{current_revision}"
        set(:repository)                  { "git@github.com:#{github_account}/#{github_repository}.git" }
      end
    end
  end
end

######################################################################
#                         GIT NOTIFIER TASKS                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before  'deploy:cleanup',           'git:tag'

  namespace :git do
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

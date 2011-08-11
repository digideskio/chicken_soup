######################################################################
#                         GIT NOTIFIER TASKS                         #
######################################################################
module ChickenSoup
  def vc_log
    `git log #{previous_revision}..#{current_revision} --pretty=format:%ai:::%an:::%s`
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  after     'deploy:base',        'notify:via_git:tag'

  namespace :notify do
    namespace :via_git do
      desc <<-DESC
        Tags the deployed Git commit with the timestamp and environment it was deployed to.

        The tag is auto-pushed to whatever `remote` is set to as well as `origin`.
        Tag push happens in the background so it won't slow down deployment.
      DESC
      task :tag do
        tag_name = "deployment/#{rails_env}/#{current_release}"

        `git tag -a -m "Tagging deploy to #{rails_env} at #{current_release}" #{tag_name} #{branch}`
        `git push #{remote} --tags > /dev/null 2>&1 &`
        `git push origin --tags > /dev/null 2>&1 &`
      end
    end
  end
end

######################################################################
#                          SUBVERSION TASKS                          #
######################################################################
module ChickenSoup
  def vc_log
    `svn log -r #{previous_revision.to_i + 1}:#{current_revision}`
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  # Implement me!
end

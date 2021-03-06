######################################################################
#                          GITHUB TASKS                              #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :git do
    desc <<-DESC
      Opens the default browser so that you can view the commit that
      is currently on the specified environment.
    DESC
    task :browse do
      `open #{github_url}/tree/#{current_revision}`
    end
  end
end

######################################################################
#                            APACHE CHECKS                           #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :check do
      desc <<-DESC
        [internal] Checks to see if all necessary Apache capabilities variables have been set up.
      DESC
      task :apache do
        required_variables = [
          :web_server_control_script
        ]

        verify_variables(required_variables)
      end
    end
  end
end

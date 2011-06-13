######################################################################
#                              DB CHECKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :check do
      desc <<-DESC
        [internal] Checks to see if all necessary DB capabilities variables have been set up.
      DESC
      task :db do
        required_variables = [
          :skip_backup_before_migration
        ]

        verify_variables(required_variables)
      end
    end
  end
end

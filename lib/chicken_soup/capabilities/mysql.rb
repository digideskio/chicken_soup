######################################################################
#                            MYSQL TASKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require 'chicken_soup/capabilities/shared/db'

  namespace :db do
    desc <<-DESC
      Creates the MySQL database and user for the application.

      * Creates a script that is uploaded to the user's home directory.
      * The script is executed as `root` and as such, the user will be prompted
        for `root`'s password.
      * The DB and user name are equivalent to the application_underscored
        variable.
      * The DB user will be granted all privileges on the DB.
    DESC
    task :create do
      create_script = <<-CREATESCRIPT
        create database #{application_underscored} character set utf8;
        create user '#{application_underscored}'@'localhost' identified by '#{db_app_password}';
        grant all on #{application_underscored}.* to #{application_underscored}@localhost;
      CREATESCRIPT

      put create_script, "#{user_home}/create_#{application_underscored}_db_script"
      run %Q{#{sudo} bash -c "mysql --user=root --password=#{db_root_password} < #{user_home}/create_#{application_underscored}_db_script"}
      run "rm #{user_home}/create_#{application_underscored}_db_script"
    end

    desc <<-DESC
      Drops the MySQL database and user for the application.

      * Creates a script that is uploaded to the user's home directory.
      * The script is executed as `root` and as such, the user will be prompted
        for `root`'s password.
    DESC
    task :drop do
      drop_script = <<-DROPSCRIPT
        drop user #{application_underscored}@localhost;
        drop database #{application_underscored};
      DROPSCRIPT

      put drop_script, "#{user_home}/drop_#{application_underscored}_db_script"
      run %Q{#{sudo} bash -c "mysql --user=root --password=#{db_root_password} < #{user_home}/drop_#{application_underscored}_db_script"}
      run "rm #{user_home}/drop_#{application_underscored}_db_script"
    end
  end
end

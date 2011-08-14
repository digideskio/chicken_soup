######################################################################
#                            LOG TASKS                               #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :log do
    desc <<-DESC
      Calls the rake task `db:backup` on the server for the given environment.

      * The backup file is placed in a directory called `db_backups` under the `shared`
        directory by default.
      * The filenames are formatted with the timestamp of the backup.
      * After export, each file is zipped up using a bzip2 compression format.
    DESC
    task :default, :roles => :app do
      run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
        trap("INT") { puts 'Log tailing aborted...'; exit 0; }

        puts  # for an extra line break before the host name
        puts "#{channel[:host]}: #{data}"

        break if stream == :err
      end
    end
  end
end

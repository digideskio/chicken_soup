######################################################################
#                           PASSENGER TASKS                          #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    desc <<-DESC
      There is no way to start the application via Passenger.

      This task does nothing.
    DESC
    task :start do ; end

    desc <<-DESC
      There is no way to stop the application via Passenger.

      This task does nothing.
    DESC
    task :stop do ; end

    desc <<-DESC
      Starts/Restarts the application.

      Passenger knows when you'd like to reset by looking at a file in the `tmp`
      directory called `restart.txt`.  If the Last Access time for `restart.txt`
      changes, Passenger restarts the app.
    DESC
    task :restart, :except => { :no_release => true } do
      run "touch #{File.join( current_path, 'tmp', 'restart.txt' )}"
    end
  end
end

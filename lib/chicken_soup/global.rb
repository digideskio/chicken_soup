###
# Helper method to close all session connections to the remote servers
#
def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

###
# Forces all connections to switch to the user passed into it.
#
# It will forcibly terminate all open connections in order to accomplish this.
#
# @example Switch to the 'deploy' user:
#   set_user_to 'deploy'
#
# @param [String] username The username you would like to begin using.
#
def set_user_to(username)
  close_sessions
  set :user,        username
  set(:password)    {Capistrano::CLI.password_prompt("#{username.capitalize}'s Password: ")}
  set(:user_home)   { user == "root" ? "/root" : "/home/#{username}" }
end

###
# Helper method to run tasks in different contexts.
#
# The workflow is as follows:
# * Current user is saved
# * User is switched to the desired username passed in via the :as option
# * The task is run
# * The user is switched back to the original user
#
# By default the task hooks are prepared but the task itself is not executed.
# You can change this by passing :now as an option.
#
# Running a task 'now' does not create hooks. Standard calls to the task will
# be executed via the current user.
#
# @example Always run the task to install gems as the 'manage' user:
#   run_task 'gems:install', :as => 'manage'
# @example Run the db migration task now as the 'deploy' user:
#   run_task 'db:migrate', :as => 'deploy', :now => true
#
# @param [String] task_name The name of the task to run.
# @param [Hash] options Options to customize how the task is run.  Valid options are:
# @option options [Boolean] :now - If present, the task will be executed immediately.
# @option options [String]  :as - The name of the user you wish the task to be executed as.
#
# @todo Remove all previous hooks prior to adding new ones.  Also disable hooks when running "now"
#
def run_task(task_name, options = {})
  raise "#run_task must be passed an `:as` option so that it knows who to change the user to." unless options[:as]

  original_username = exists?(:user) ? user : nil

  if options[:now]
    set_user_to options[:as]
    find_and_execute_task(task_name)
    set_user_to original_username
  else
    before task_name,     "os:users:#{options[:as]}:use"
    after  task_name,     "os:users:#{original_username}:use"
  end
end

###
# Checks an array of items to see if they are currently set within the
# Capistrano scope.  If any of them fail, Capistrano execution will terminate.
#
# @param [Array, #each] required_variables An iterable list of items which
#   represent the names of Capistrano environment variables.  Each item in this
#   list is expected to be set.
#
# @raise [CapistranoGoBoom] Calls #abort on the Capistrano execution if any of
#   the variables are not set.
#
# @example Using an array:
#   verify_variables [:user, :deploy_dir, :app_server]
#
def verify_variables(required_variables)
  required_variables.each do |expected_variable|
    abort( "You have not defined '#{expected_variable}' which is necessary for deployment." ) unless exists?(expected_variable)
  end
end

###
# @note Taken directly from the Capistrano codebase.
#
# Sets a variable only if it doesn't already exist.
#
def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

###
# Runs a command on the remote server to see if the file currently exists.
#
# @param [String] file The filename (optionally including path) that is may
#   or may not exist.
#
# @return [Boolean] Whether or not the file exists.
#
# @example File without path:
#   remote_file_exists? 'server.log'
# @example File with path:
#   remote_file_exists? '/var/www/myappdir/log/production.log'
#
def remote_file_exists?(file)
  capture("if [ -f #{file} ]; then echo 'exists'; fi;").chomp == "exists"
end

module ChickenSoup
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
    abort "#run_task must be passed an `:as` option so that it knows who to change the user to." unless options[:as]

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
  #   verify_variables [:user, :deploy_base_dir, :app_server]
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
  # @param [String] file The filename (optionally including path), directory,
  #   or symlink that is may or may not exist.
  #
  # @return [Boolean] Whether or not the file, directory or symlink exists.
  #
  # @example File without path:
  #   remote_file_exists? 'server.log'
  # @example File with path:
  #   remote_file_exists? '/var/www/myappdir/log/production.log'
  # @example Directory:
  #   remote_file_exists? '/var/www/myappdir/log'
  # @example Symbolic Link:
  #   remote_file_exists? '/var/www/myappdir/current'
  #
  def remote_file_exists?(file)
    capture("if [[ -d #{file} ]] || [[ -h #{file} ]] || [[ -f #{file} ]]; then echo -n 'exists'; fi;") == "exists"
  end

  ###
  # Will require a file but will not throw an error if that file does not
  # exist.
  #
  # @param [String] file The filename (optionally including path), directory,
  #   or symlink that is may or may not exist.
  #
  # @return [nil] nil will be returned if the file was loaded successfully.
  #
  # @example
  #   require_if_exists 'my_library'
  #
  def require_if_exists(file)
    require file if File.exists?(File.join(File.dirname(__FILE__), '..', "#{file}.rb"))
  end

  ###
  # Compresses a specific remote file before transferring it to the local
  # machine.  Once the transfer is completed, the file will be uncompressed
  # and the compressed version will be deleted.
  #
  # @param [String] remote The remote filename (optionally including path),
  # or directory that you would like to transfer.
  #
  # @param [String] local The location locally where you would like the file
  # or directory to be transferred.
  #
  # @param [String] options Any options that can be passed to Capistrano's
  # #download method.
  #
  # @example
  #   download_compressed 'my/remote/file', 'my/local/file', :once => true
  #
  def download_compressed(remote, local, options = {})
    remote_compressed_filename = "#{remote}.bz2"
    local_compressed_filename  = "#{local}.bz2"

    run "bzip2 -zvck9 #{remote} > #{remote_compressed_filename}"
    download remote_compressed_filename, local_compressed_filename, options

    run "rm -f #{remote_compressed_filename}"
    `bunzip2 -f #{local_compressed_filename} && rm -f #{local_compressed_filename}`
  end

  ###
  # A stub method which simply passes through to Capistrano's #run.  This
  # method is meant to be overridden when a Ruby manager capability (ie RVM)
  # is installed.
  #
  # @param [String] ruby_version This is simply a noop on this method.  It
  # is not used.  It is instead intended to be used with the Ruby manager
  # that is installed.
  #
  # @param [String] command The command that is passed to #run
  #
  # @param [String] options Any options that can be passed to Capistrano's
  # #run method.
  #
  # @example
  #   run_with_ruby_manager 'foo', 'gem list', :pty => false
  #
  def run_with_ruby_manager(ruby_version, command, options = {})
    run command, options
  end

  ###
  # A stub method which simply returns nil.  It is meant to be overridden
  # when a version control capability (ie Git) is installed.
  #
  # @return [nil] Always returns nil
  #
  # @example
  #   run_with_ruby_manager 'foo', 'gem list', :pty => false
  #
  def vc_log
    nil
  end

  def lookup_ip_for(hostname)
    ip = `nslookup #{hostname} | tail -n 2 | head -n 1 | cut -d ' ' -f 2`.chomp
    ip != '' ? ip : nil
  end
end

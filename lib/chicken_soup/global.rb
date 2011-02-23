def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

def set_user_to(username)
  close_sessions
  set :user,        username
  set(:password)    {Capistrano::CLI.password_prompt("#{username.capitalize}'s Password: ")}
  set(:user_home)   { user == "root" ? "/root" : "/home/#{username}" }
end

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

def verify_variables(required_variables)
  required_variables.each do |expected_variable|
    abort( "You have not defined '#{expected_variable}' which is necessary for deployment." ) unless exists?(expected_variable)
  end
end

# Taken from the capistrano code.
def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

def remote_file_exists?(file)
  capture("if [ -f #{file} ]; then echo 'exists'; fi;").chomp == "exists"
end

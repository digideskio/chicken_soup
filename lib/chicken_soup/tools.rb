######################################################################
#                           TOOLS SETUP                              #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  require "chicken_soup/tools/defaults"
  require "chicken_soup/tools/tasks"

  ['defaults', 'checks', 'tasks'].each do |method|
    desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
    task "load_tool_#{method}".to_sym do
      fetch(:tools).each do |tool|
        require_if_exists "chicken_soup/tools/#{tool}/#{tool}-#{method}"
      end
    end
  end
end

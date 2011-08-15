######################################################################
#                       DEFAULT TOOLS SETUP
#
# The 'tools:defaults' task hooks itself into the deployment
# stream by attaching an after hook to 'environment:defaults'.
#
# Prior to execution, all of the tools which were specified in
# the deploy.rb file are loaded and then each tool has its
# 'defaults' task called.
#
# All tools's defaults tasks are in the format:
#   tools:defaults:<tool_name>
#
# Defaults tasks are there simply to set standard conventional
# standards on each tool.  In almost all cases, they can
# be overridden.
#
# Defaults are also optional.  If a tools doesn't require any
# environment variables to be set, it can simply omit a defaults task.
#
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  before  'tools:defaults',      'load_tool_defaults'

  namespace :tools do
    namespace :defaults do
      desc <<-DESC
        [internal] Installs all tools for the given deployment type.

        Most of these values can be overridden in each application's deploy.rb file.
      DESC
      task :default do
        if exists?(:tools)
          fetch(:tools).each do |tool|
            tools.defaults.send(tool.to_s) if tools.defaults.respond_to?(tool.to_sym)
          end
        end
      end
    end
  end
end

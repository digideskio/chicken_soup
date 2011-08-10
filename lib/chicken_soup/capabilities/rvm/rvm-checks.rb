######################################################################
#                             RVM CHECKS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  extend ChickenSoup

  namespace :capabilities do
    namespace :variable do
      namespace :check do
        desc <<-DESC
          [internal] Checks to see if all necessary RVM variables have been set up.
        DESC
        task :rvm do
          required_variables = [
            :rvmrc_file,
            :ruby_version,
            :ruby_gemset,
            :full_ruby_environment_string,
          ]

          verify_variables(required_variables)
        end
      end
    end

    namespace :deployment do
      namespace :check do
        task :rvm do
          abort "Could not find an .rvmrc file at #{rvmrc_file}. To use the RVM capability, you must have a valid local .rvmrc file." unless File.exist?(rvmrc_file)

          rvmrc_file_contents         = capture("cat #{current_path}/.rvmrc", :roles => :app)
          set :current_rvm_ruby_string, rvmrc_file_contents.match(ChickenSoup::RVM_INFO_FORMAT)[1]

          unless ruby_version_update_pending
            abort "'#{full_ruby_environment_string}' does not match the version currently installed on the server (#{current_rvm_ruby_string}).  Please run 'cap <environment> ruby:update deploy:subzero' if you would like to upgrade your Ruby version prior to deploying." unless current_rvm_ruby_string == rvm_ruby_string
          end
        end
      end
    end
  end
end

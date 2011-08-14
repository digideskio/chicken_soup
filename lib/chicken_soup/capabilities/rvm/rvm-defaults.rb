######################################################################
#                           RVM DEFAULTS                             #
######################################################################
module ChickenSoup
  RVM_INFO_FORMAT = /^rvm.+\s(([a-zA-Z0-9\-\._]+)(?:@([a-zA-Z0-9\-\._]+))?)/
end

Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      _cset :rvmrc_file,                    File.join(rails_root, '.rvmrc')
      set   :ruby_version_update_pending,   false

      _cset(:ruby_version)        do
        contents = File.read(rvmrc_file)
        contents.match(ChickenSoup::RVM_INFO_FORMAT)[2]
      end

      _cset(:ruby_gemset)         do
        contents = File.read(rvmrc_file)
        contents.match(ChickenSoup::RVM_INFO_FORMAT)[3]
      end

      _cset(:full_ruby_environment_string)      {ruby_gemset ? "#{ruby_version}@#{ruby_gemset}" : ruby_version}
    end
  end
end

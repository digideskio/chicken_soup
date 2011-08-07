######################################################################
#                           RVM DEFAULTS                             #
######################################################################
ChickenSoup::RVM_INFO_FORMAT = /^rvm.+\s(([a-zA-Z0-9\-\._]+)(?:@([a-zA-Z0-9\-\._]+))?)/

Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      _cset :rvmrc_file,          File.join(rails_root, '.rvmrc')

      _cset(:ruby_version)        do
        contents = File.read(rvmrc_file)
        contents.match(ChickenSoup::RVM_INFO_FORMAT)[2]
      end

      _cset(:rvm_gemset)          do
        contents = File.read(rvmrc_file)
        contents.match(ChickenSoup::RVM_INFO_FORMAT)[3]
      end

      _cset(:rvm_ruby_string)     {rvm_gemset ? "#{ruby_version}@#{rvm_gemset}" : ruby_version}
    end
  end
end

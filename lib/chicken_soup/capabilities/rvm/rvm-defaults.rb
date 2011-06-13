######################################################################
#                           RVM DEFAULTS                             #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  namespace :capabilities do
    namespace :defaults do
      _cset :ruby_version,        ENV["rvm_ruby_string"]
      _cset :ruby_gemset,         ENV["GEM_HOME"].split('@')[1]

      _cset(:rvm_ruby_string)     {ruby_gemset ? "#{ruby_version}@#{ruby_gemset}" : ruby_version}
    end
  end
end

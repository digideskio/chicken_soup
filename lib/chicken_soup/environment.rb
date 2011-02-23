######################################################################
#                          ENVIRONMENT SETUP                         #
######################################################################
Capistrano::Configuration.instance(:must_exist).load do
  on      :start,                                 'environment:check', :except => ['staging', 'production']

  after   'production',                           'environment:defaults:production', 'environment:defaults'
  after   'staging',                              'environment:defaults:staging', 'environment:defaults'

  after   'environment:defaults:managed_server',  'load_capabilities'
  after   'environment:defaults:heroku',          'load_capabilities'

  before  'environment:check',                    'environment:check:common'

  require 'chicken_soup/environment/checks'
  require 'chicken_soup/environment/defaults'

  desc "[internal] This task is only here because `require` cannot be used within a `namespace`"
  task :load_capabilities do
    require "chicken_soup/capabilities/unix"
    capabilities.each do |capability|
      require "chicken_soup/capabilities/#{capability}"
    end
  end
end

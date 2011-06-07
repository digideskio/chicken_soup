# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chicken_soup/version"

Gem::Specification.new do |s|
  s.rubygems_version      = '1.4.2'

  s.name                  = "chicken_soup"
  s.rubyforge_project     = "chicken_soup"

  s.version               = ChickenSoup::VERSION
  s.platform              = Gem::Platform::RUBY

  s.authors               = ["thekompanee", "jfelchner"]
  s.email                 = 'support@thekompanee.com'
  s.homepage              = 'http://github.com/jfelchner/chicken_soup'

  s.summary               = "chicken_soup-#{ChickenSoup::VERSION}"
  s.description           = %q[...for the Deployment Soul.  Why do you keep typing all that crap into your Capistrano recipes?  Are you too cool for standards?  Well, ARE YA!?]

  s.rdoc_options          = ["--charset = UTF-8"]
  s.extra_rdoc_files      = %w[README.md LICENSE]

  #= Manifest =#
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths         = ["lib"]
  #= Manifest =#

  s.add_dependency('capistrano',            '~> 2.5.19')
  s.add_dependency('mail',                  '~> 2.2.15')

  s.add_development_dependency('bundler',   '~> 1.0.10')
  s.add_development_dependency('rspec',     '~> 2.6.0')
  s.add_development_dependency('yard',      '~> 0.7.1')
end

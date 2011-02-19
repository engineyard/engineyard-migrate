# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "engineyard-migrate/version"

Gem::Specification.new do |s|
  s.name        = "engineyard-migrate"
  s.version     = Engineyard::Migrate::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dr Nic Williams", "Danish Khan"]
  s.email       = ["drnicwilliams@gmail.com"]
  s.homepage    = "https://github.com/engineyard/engineyard-migrate"
  s.summary     = %q{Migrate up to Engine Yard AppCloud from Heroku or similar.}
  s.description = %q{Want to migrate your Ruby on Rails application from Heroku (or similar) up to Engine Yard AppCloud? This is the tool for you.}

  s.rubyforge_project = "engineyard-migrate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("engineyard", ["~> 1.3.16"])
  s.add_dependency("heroku", ["~> 1.17.10"])
  s.add_dependency("POpen4", ["~> 0.1.4"])
  s.add_dependency("net-sftp", ["~> 2.0.5"])

  s.add_development_dependency("awesome_print")
  s.add_development_dependency("builder", ["2.1.2"]) # for test app
  s.add_development_dependency("rails", ["3.0.3"]) # for test app
  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("cucumber", ["~> 0.10.0"])
  s.add_development_dependency("cucumber-rails", ["~> 0.3.2"])
  s.add_development_dependency("rspec", ["~> 2.2.0"])
  s.add_development_dependency("nokogiri", ["~> 1.4.0"])
  s.add_development_dependency("ssh-config")
  s.add_development_dependency("taps", ["~> 0.3.15"])
end

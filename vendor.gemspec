# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|

  s.name        = "vendor"
  s.version     = File.read("VERSION").chomp
  s.authors     = ["keithpitt"]
  s.email       = ["me@keithpitt.com"]
  s.homepage    = "http://www.vendorkit.com"
  s.summary     = %q{Dependency management for iOS and OSX development}
  s.description = %q{Dependency management for iOS and OSX development}

  s.rubyforge_project = "vendor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "growl"

  s.add_runtime_dependency "ripl"
  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "rubyzip"
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "highline"
  s.add_runtime_dependency "xcoder", "~> 0.1.7"

end

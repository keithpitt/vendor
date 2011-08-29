# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vendor_kit/version"

Gem::Specification.new do |s|
  s.name        = "vendor_kit"
  s.version     = VendorKit::VERSION
  s.authors     = ["keithpitt"]
  s.email       = ["me@keithpitt.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "vendor_kit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "rake"
end

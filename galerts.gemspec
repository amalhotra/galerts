# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "galerts/version"

Gem::Specification.new do |s|
  s.name        = "galerts"
  s.version     = Galerts::VERSION
  s.authors     = ["Ankit Malhotra"]
  s.email       = ["amalhotra15.9@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby library to manage google alerts}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "galerts"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

	s.add_dependecy "mechanize"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

# -*- encoding: utf-8 -*-
# regards to Marcin Bunsch, creator of dropbox-api gem.
$:.push File.expand_path("../lib", __FILE__)
require "cloudpt-api/version"

Gem::Specification.new do |s|
  s.name        = "cloudpt-api"
  s.version     = Cloudpt::API::VERSION
  s.authors     = ["Fabio Batista"]
  s.email       = ["fbatista@webreakstuff.com"]
  s.homepage    = "http://github.com/fbatista/cloudpt-api"
  s.summary     = "A Ruby client for the cloudpt REST API."
  s.description = "To deliver a more Rubyesque experience when using the cloudpt API."

  s.rubyforge_project = "cloudpt-api"

  s.add_dependency 'multi_json'
  s.add_dependency 'oauth'
  s.add_dependency 'hashie'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

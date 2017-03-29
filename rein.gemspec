lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rein/version"

Gem::Specification.new do |spec|
  spec.name        = "rein"
  spec.version     = Rein::VERSION
  spec.author      = "Joshua Bassett"
  spec.email       = "josh.bassett@gmail.com"
  spec.summary     = "Database constraints made easy for ActiveRecord."
  spec.description = "Rein adds bunch of methods to your ActiveRecord migrations so you can easily tame your database."
  spec.homepage    = "http://github.com/nullobject/rein"
  spec.license     = "MIT"
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 4.0.0", "< 6"
  spec.add_runtime_dependency "activesupport", ">= 4.0.0", "< 6"

  spec.add_development_dependency "appraisal", "~> 2.1"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0.47"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
end

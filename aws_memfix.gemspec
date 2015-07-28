# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_memfix/version'

Gem::Specification.new do |spec|
  spec.name          = "aws_memfix"
  spec.version       = AwsMemfix::VERSION
  spec.authors       = ["Milovan Zogovic"]
  spec.email         = ["milovan.zogovic@gmail.com"]

  spec.summary       = %q{Fixes ruby 2.2.x StringIO memory leaks for AWS Seahorse client}
  spec.homepage      = "https://github.com/assembler/aws-sdk-ruby-memory-fix"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = [">= 2.2.0", "< 2.2.3"]

  spec.add_dependency "aws-sdk", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end

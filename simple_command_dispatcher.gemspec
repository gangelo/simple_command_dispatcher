# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_command_dispatcher/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_command_dispatcher"
  spec.version       = SimpleCommandDispatcher::VERSION
  spec.authors       = ["Gene M. Angelo, Jr."]
  spec.email         = ["public.gma@gmail.com"]

  spec.summary       = %q{Provides a way to dispatch simple_command commands dynamically within an API where multiple applications and/or API versions will be necessary.}
  spec.description   = %q{Provides a way to dispatch simple_command commands dynamically within an API where multiple applications and/or API versions will be necessary.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "yard", "0.9.5"
  spec.add_development_dependency "redcarpet", '3.3.4'

  spec.required_ruby_version = '>= 2.0'
  spec.add_runtime_dependency 'simple_command', '>= 0.0.9'
end

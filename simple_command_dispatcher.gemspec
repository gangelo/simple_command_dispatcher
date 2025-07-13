# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_command_dispatcher/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_command_dispatcher'
  spec.version       = SimpleCommandDispatcher::VERSION
  spec.authors       = ['Gene M. Angelo, Jr.']
  spec.email         = ['public.gma@gmail.com']

  spec.summary       = 'Dynamic command dispatch for Rails and Rails API applications using the Command Pattern with convention over configuration.'
  spec.description   = 'A lightweight Ruby gem that enables Rails and Rails API applications to dynamically dispatch command objects using flexible string-based naming. ' \
                       'Perfect for implementing the Command Pattern with convention over configuration, RESTful route conversion, and flexible namespacing. ' \
                       'Supports multiple input formats, Unicode handling, and works seamlessly with Rails controllers, background jobs, and service layers. ' \
                       'No external dependencies beyond ActiveSupport. Ideal for clean, maintainable Rails applications.'
  spec.homepage      = 'https://github.com/gangelo/simple_command_dispatcher'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 3.3', '< 4.0')

  spec.add_runtime_dependency 'activesupport', '>= 7.0.8', '< 9.0'
end

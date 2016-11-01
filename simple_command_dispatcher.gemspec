# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_command_dispatcher/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_command_dispatcher"
  spec.version       = SimpleCommand::Dispatcher::VERSION
  spec.authors       = ["Gene M. Angelo, Jr."]
  spec.email         = ["public.gma@gmail.com"]

  spec.summary       = %q{Provides a way to dispatch simple_command ruby gem SimpleCommands (service objects) in a more dynamic manner within your service API. Ideal for rails-api.}
  spec.description   = %q{Within a services API (rails-api for instance), you may have a need to execute different SimpleCommands
                          based on one or more factors: multiple application, API version, user type, user credentials, etc. For example, 
                          your service API may need to execute either Api::Auth::V1::AuthenticateCommand.call(...) or Api::Auth::V2::AuthenticateCommand.call(...)
                          based on the API version. simple_command_dispatcher allows you to make one call to execute both command dynamically.}.gsub(/\s+/,' ')
  spec.homepage      = "https://github.com/gangelo/simple_command_dispatcher"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "yard"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "colorize"

  spec.required_ruby_version = '>= 2.2.2'
  spec.add_runtime_dependency 'activesupport', '~> 5.0', '>= 5.0.0.1'

  spec.add_runtime_dependency 'simple_command', '>= 0.0.9'
end

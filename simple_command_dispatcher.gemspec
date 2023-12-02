# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_command_dispatcher/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_command_dispatcher'
  spec.version       = SimpleCommand::Dispatcher::VERSION
  spec.authors       = ['Gene M. Angelo, Jr.']
  spec.email         = ['public.gma@gmail.com']

  spec.summary       = 'Provides a way to dispatch simple_command (ruby gem) commands or your own custom commands (service objects) in a more dynamic manner
                          within your service API. Ideal for rails-api.'
  spec.description   = 'Within a services API (rails-api for instance), you may have a need to execute different simple_commands or your own custom commands (service objects)
                          based on one or more factors: multiple application, API version, user type, user credentials, etc. For example,
                          your service API may need to execute either Api::Auth::V1::AuthenticateCommand.call(...) or Api::Auth::V2::AuthenticateCommand.call(...)
                          based on the API version. simple_command_dispatcher allows you to execute either command with one line of code dynamically.'.gsub(/\s+/, ' ')
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

  spec.required_ruby_version = '>= 2.7.0'
  spec.add_runtime_dependency 'activesupport', '>= 7.0.8', '< 8.0'
  spec.add_runtime_dependency 'simple_command', '>= 0.2.0', '< 1.0'

  spec.add_development_dependency 'pry-byebug', '>= 3.9', '< 4.0'
  spec.add_development_dependency 'bundler', '>= 2.4', '< 3.0'
  spec.add_development_dependency 'colorize', '>= 0.8.1', '< 1.0'
  spec.add_development_dependency 'rake', '>= 13.0', '< 14.0'
  spec.add_development_dependency 'rdoc', '>= 6.4', '< 7.0'
  spec.add_development_dependency 'rspec', '>= 3.10', '< 4.0'
  spec.add_development_dependency 'rubocop', '>= 1.35', '< 2.0'
  spec.add_development_dependency 'rubocop-performance', '>= 1.14', '< 2.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.25'
  spec.add_development_dependency 'yard', '>= 0.9.28', '< 1.0'
end

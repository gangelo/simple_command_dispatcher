# Installation Guide

Complete installation instructions for simple_command_dispatcher.

## Requirements

- **Ruby:** >= 3.3.0, < 4.0
- **Rails:** Optional, but optimized for Rails applications
- **ActiveSupport:** >= 7.0.8, < 9.0 (automatically installed as dependency)

## Installation Methods

### Method 1: Using Bundler (Recommended)

Add this line to your application's `Gemfile`:

```ruby
gem 'simple_command_dispatcher'
```

Then execute:

```bash
bundle install
```

### Method 2: Direct Installation

Install directly using gem:

```bash
gem install simple_command_dispatcher
```

Then add to your `Gemfile`:

```ruby
gem 'simple_command_dispatcher'
```

## Verification

Verify the installation:

```bash
bundle info simple_command_dispatcher
```

Or check in Ruby:

```ruby
require 'simple_command_dispatcher'
puts SimpleCommandDispatcher::VERSION
```

## Configuration (Optional)

Create an initializer to configure the gem:

```bash
# Rails applications
touch config/initializers/simple_command_dispatcher.rb
```

Add configuration:

```ruby
# config/initializers/simple_command_dispatcher.rb
SimpleCommandDispatcher.configure do |config|
  # Set the logger (defaults to Rails.logger in Rails apps)
  config.logger = Rails.logger

  # Or use a custom logger
  # config.logger = Logger.new('log/commands.log')
end
```

### Default Configuration

If you don't create an initializer, SCD uses these defaults:

- **In Rails apps:** Uses `Rails.logger` automatically
- **In non-Rails apps:** Uses `Logger.new($stdout)`

## Directory Structure Setup

Create the commands directory:

```bash
mkdir -p app/commands
```

For namespaced commands:

```bash
mkdir -p app/commands/api/v1
```

## Rails Integration

### Rails 7.x and 8.x

simple_command_dispatcher is fully compatible with Rails 7 and 8. No special configuration needed.

### Eager Loading

Ensure your commands directory is eager loaded in `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # ...

    # Commands should be eager loaded in production
    config.eager_load_paths << Rails.root.join('app', 'commands')
  end
end
```

This is typically already configured by Rails for the `app/commands` directory.

## Non-Rails Ruby Applications

For non-Rails Ruby projects:

1. **Install the gem:**

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'simple_command_dispatcher'
gem 'activesupport'  # Required dependency
```

2. **Require in your application:**

```ruby
require 'simple_command_dispatcher'

# Configure (optional)
SimpleCommandDispatcher.configure do |config|
  config.logger = Logger.new($stdout)
end
```

3. **Create command classes:**

```ruby
# lib/commands/my_command.rb
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Hello from MyCommand!"
  end
end
```

4. **Call commands:**

```ruby
command = MyCommand.call
puts command.result  # => "Hello from MyCommand!"
```

## Upgrading from Previous Versions

### From v3.x to v4.x

See the [Migration Guide](Migration-Guide.md) for detailed upgrade instructions.

Quick overview:

1. **Update Gemfile:**

```ruby
# Change from:
gem 'simple_command_dispatcher', '~> 3.0'

# To:
gem 'simple_command_dispatcher', '~> 4.0'
```

2. **Run bundle update:**

```bash
bundle update simple_command_dispatcher
```

3. **Update method calls** (keyword arguments required):

```ruby
# Old (v3.x)
SimpleCommandDispatcher.call(:Command, 'Namespace', {}, params)

# New (v4.x)
SimpleCommandDispatcher.call(
  command: :Command,
  command_namespace: 'Namespace',
  request_params: params
)
```

## Troubleshooting Installation

### Bundle Install Fails

If `bundle install` fails, try:

```bash
bundle update
```

Or specify a version:

```ruby
gem 'simple_command_dispatcher', '~> 4.2'
```

### LoadError: cannot load such file

Ensure the gem is in your `Gemfile` and run:

```bash
bundle install
```

Then restart your Rails server or application.

### Version Conflicts

If you encounter version conflicts with ActiveSupport:

```bash
bundle update activesupport
```

Or pin a specific version:

```ruby
gem 'activesupport', '~> 7.0'
gem 'simple_command_dispatcher'
```

## Verifying Installation

Create a test command:

```ruby
# app/commands/test_installation.rb
class TestInstallation
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Installation successful!"
  end
end
```

Test it in Rails console:

```ruby
rails console

command = TestInstallation.call
puts command.result  # => "Installation successful!"
puts command.success?  # => true
```

Or through the dispatcher:

```ruby
command = SimpleCommandDispatcher.call(
  command: :test_installation
)
puts command.result  # => "Installation successful!"
```

## Next Steps

After installation:

1. [Follow the Quick Start tutorial](Quick-Start.md)
2. [Understand Core Concepts](Core-Concepts.md)
3. [Create your first command](Creating-Commands.md)
4. [Explore real-world examples](Examples-Authentication.md)

## Getting Help

- **GitHub Issues:** [Report installation problems](https://github.com/gangelo/simple_command_dispatcher/issues)
- **RubyDoc:** [API Documentation](http://www.rubydoc.info/gems/simple_command_dispatcher/)
- **Demo App:** [See it in action](https://github.com/gangelo/simple_command_dispatcher_demo_app)

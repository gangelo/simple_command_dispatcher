[![Ruby](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml/badge.svg?refresh=9)](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml)
[![GitHub version](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher.svg?refresh=9)](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher)
[![Gem Version](https://badge.fury.io/rb/simple_command_dispatcher.svg?refresh=9)](https://badge.fury.io/rb/simple_command_dispatcher)
[![](https://ruby-gem-downloads-badge.herokuapp.com/simple_command_dispatcher?type=total)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/simple_command_dispatcher/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

# simple_command_dispatcher

## Overview

**simple_command_dispatcher** (SCD) allows your Rails or Rails API application to _dynamically_ call backend command services from your Rails controller actions using a flexible, convention-over-configuration approach.

📋 **See it in action:** Check out the [demo application](https://github.com/gangelo/simple_command_dispatcher_demo_app) - a Rails API app with tests that demonstrate how to use the gem and its capabilities.

📚 **Complete Documentation:** Visit the [comprehensive wiki](https://github.com/gangelo/simple_command_dispatcher/wiki) for in-depth guides, real-world examples, and advanced usage patterns.

## Features

- 🛠️ **Convention Over Configuration**: Call commands dynamically from controller actions using action routes and parameters
- 🎭 **Command Standardization**: Optional `CommandCallable` module for consistent command interfaces with built-in success/failure tracking
- 🚀 **Dynamic Route-to-Command Mapping**: Automatically transforms request paths into Ruby class constants
- 🔄 **Intelligent Parameter Handling**: Supports Hash, Array, and single object parameters with automatic detection
- 🌐 **Flexible Input Formats**: Accepts strings, arrays, symbols with various separators and Unicode support
- ⚡ **Performance Optimized**: Uses Rails' proven camelization methods for fast route-to-constant conversion
- 📦 **Lightweight**: Minimal dependencies - only ActiveSupport for reliable camelization

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_command_dispatcher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_command_dispatcher

## Requirements

- Ruby >= 3.3.0
- Rails (optional, but optimized for Rails applications)
- Rails 8 compatible (tested with ActiveSupport 8.x)

## Quick Start

Here's a complete minimal example showing how to use the gem in a Rails controller:

```ruby
# 1. Configure the gem (optional - uses Rails.logger by default)
# config/initializers/simple_command_dispatcher.rb
SimpleCommandDispatcher.configure do |config|
  config.logger = Rails.logger
end

# 2. Create a command
# app/commands/api/v1/authenticate_user.rb
module Api
  module V1
    class AuthenticateUser
      prepend SimpleCommandDispatcher::Commands::CommandCallable

      def call
        user = User.find_by(email: email)
        return nil unless user&.authenticate(password)

        user
      end

      private

      def initialize(params = {})
        @email = params[:email]
        @password = params[:password]
      end

      attr_reader :email, :password
    end
  end
end

# 3. Call the command from your controller
# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
  def create
    command = SimpleCommandDispatcher.call(
      command: request.path,           # "/api/v1/authenticate_user"
      request_params: params
    )

    if command.success?
      render json: { user: command.result }, status: :ok
    else
      render json: { errors: command.errors }, status: :unauthorized
    end
  end
end
```

## Basic Usage

### Simple Command Dispatch

```ruby
# Basic command calls - all equivalent

command = SimpleCommandDispatcher.call(
  command: '/api/v1/authenticate_user',
  # No `command_namespace:` param
  request_params: { email: 'user@example.com', password: 'secret' }
)

command = SimpleCommandDispatcher.call(
  command: :authenticate_user,
  command_namespace: '/api/v1',
  request_params: { email: 'user@example.com', password: 'secret' }
)

command = SimpleCommandDispatcher.call(
  command: 'AuthenticateUser',
  command_namespace: %w[api v1],
  request_params: { email: 'user@example.com', password: 'secret' }
)

# With debug logging enabled
command = SimpleCommandDispatcher.call(
  command: '/api/v1/authenticate_user',
  request_params: { email: 'user@example.com', password: 'secret' },
  options: { debug: true }  # Enables detailed debug logging
)

# All the above will execute: Api::V1::AuthenticateUser.call(email: 'user@example.com', password: 'secret')
```

## Command Standardization with CommandCallable

The gem includes a powerful `CommandCallable` module that standardizes your command classes, providing automatic success/failure tracking, error handling, and a consistent interface. This module is completely optional but highly recommended for building robust, maintainable commands.

### The Real Power: Dynamic Command Execution using convention over configuration

Where this gem truly shines is its ability to **dynamically execute commands** using a **convention over configuration** approach. Command names and namespacing match controller action routes, making it possible to dynamically execute commands based on controller/action routes and pass arguments dynamically using params.

Here's how it works with a real controller example:

```ruby
# app/controllers/api/mechs_controller.rb
class Api::MechsController < ApplicationController
  before_action :route_request, except: [:destroy, :index]

  def index
    render json: { mechs: Mech.all }
  end

  def search
    # Action intentionally left empty, routing handled by before_action
  end

  private

  def route_request
    command = SimpleCommandDispatcher.call(
      command: request.path,        # "/api/v1/mechs/search"
      # No need to use the `command_namespace` param, since the command namespace
      # can be gleaned directly from `command: request.path`.
      request_params: params        # Full Rails params hash
    )

    if command.success?
      render json: { mechs: command.result }, status: :ok
    else
      render json: { errors: command.errors }, status: :unprocessable_entity
    end
  end
end
```

**The Convention:** Request path `/api/v1/mechs/search` automatically maps to command class `Api::V1::Mechs::Search`.

**Alternative approach** for handling nested resource routes with dynamic actions:

```ruby
# Handle routes like: /api/v1/mechs/123/variants/456/update
# Extract resource action and build namespace from nested resources
path_parts = request.path.split("/")
action = path_parts.last                    # "update"
resource_path = path_parts[0...-1]          # ["/api", "v1", "mechs", "123", "variants", "456"]

# Build namespace from resource path, filtering out IDs
namespace_parts = resource_path.select { |part| !part.match?(/^\d+$/) }

command = SimpleCommandDispatcher.call(
  command: action,                          # "update"
  command_namespace: namespace_parts,       # ["/api", "v1", "mechs", "variants"]
  request_params: params.merge(
    mech_id: path_parts[4],                 # "123"
    variant_id: path_parts[6]               # "456"
  )
)
# Calls: Api::V1::Mechs::Variants::Update.call(mech_id: "123", variant_id: "456", ...)
```

### Versioned Command Examples

```ruby
# app/commands/api/v1/mechs/search.rb
class Api::V1::Mechs::Search
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # V1 search logic - simple name search
    name.present? ? Mech.where("mech_name ILIKE ?", "%#{name}%") : Mech.none
  end

  private

  def initialize(params = {})
    @name = params[:name]
  end

  attr_reader :name
end

# app/commands/api/v2/mechs/search.rb
class Api::V2::Mechs::Search
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # V2 search logic - comprehensive search using scopes
    Mech.by_cost(cost)
        .or(Mech.by_introduction_year(introduction_year))
        .or(Mech.by_mech_name(mech_name))
        .or(Mech.by_tonnage(tonnage))
        .or(Mech.by_variant(variant))
  end

  private

  def initialize(params = {})
    @cost = params[:cost]
    @introduction_year = params[:introduction_year]
    @mech_name = params[:mech_name]
    @tonnage = params[:tonnage]
    @variant = params[:variant]
  end

  attr_reader :cost, :introduction_year, :mech_name, :tonnage, :variant
end

# app/models/mech.rb (V2 scopes)
class Mech < ApplicationRecord
  scope :by_mech_name, ->(name) {
    name.present? ? where("mech_name ILIKE ?", "%#{name}%") : none
  }

  scope :by_variant, ->(variant) {
    variant.present? ? where("variant ILIKE ?", "%#{variant}%") : none
  }

  scope :by_tonnage, ->(tonnage) {
    tonnage.present? ? where(tonnage: tonnage) : none
  }

  scope :by_cost, ->(cost) {
    cost.present? ? where(cost: cost) : none
  }

  scope :by_introduction_year, ->(year) {
    year.present? ? where(introduction_year: year) : none
  }
end
```

**The Magic:** By convention, routes automatically map to commands:

- `/api/v1/mechs/search` → `Api::V1::Mechs::Search`
- `/api/v2/mechs/search` → `Api::V2::Mechs::Search`

### What CommandCallable Provides

When you prepend `CommandCallable` to your command class, you automatically get:

1. **Class Method Generation**: Automatic `.call` class method that instantiates and calls your command
2. **Result Tracking**: Your command's return value is stored in `command.result`
3. **Success/Failure Methods**: `success?` and `failure?` methods based on error state
4. **Error Handling**: Built-in `errors` object for consistent error management
5. **Call Tracking**: Internal tracking to ensure methods work correctly

**Important:** The `.call` class method returns the command instance itself (not the raw result). Access the actual return value via `.result`:

```ruby
command = AuthenticateUser.call(email: 'user@example.com', password: 'secret')
command.success?  # => true/false
command.result    # => the actual User object (or whatever your call method returned)
command.errors    # => errors collection if any
```

**Best Practice:** Make `initialize` private when using `CommandCallable`. This enforces the use of the `.call` class method and ensures proper success/failure tracking. Making `initialize` private prevents direct instantiation that would bypass CommandCallable's functionality:

```ruby
class YourCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Your logic here
  end

  private  # <- initialize should be private

  def initialize(params = {})
    @params = params
  end
end

# This works (correct pattern):
YourCommand.call(foo: 'bar')

# This raises NoMethodError (prevents bypassing CommandCallable):
YourCommand.new(foo: 'bar')
```

### Convention Over Configuration: Route-to-Command Mapping

The gem automatically transforms route paths into Ruby class constants using intelligent camelization, allowing flexible input formats:

```ruby
# All of these are equivalent and call: Api::UserSessions::V1::CreateCommand.call

# Lowercase strings with various separators
SimpleCommandDispatcher.call(
  command: :create_command,
  command_namespace: 'api::user_sessions::v1'
)

# Mixed case array
SimpleCommandDispatcher.call(
  command: 'CreateCommand',
  command_namespace: ['api', 'UserSessions', 'v1']
)

# Route-like strings (optimized for Rails controllers)
SimpleCommandDispatcher.call(
  command: '/create_command',
  command_namespace: '/api/user_sessions/v1'
)

# Mixed separators (hyphens, dots, spaces)
SimpleCommandDispatcher.call(
  command: 'create-command',
  command_namespace: 'api.user-sessions/v1'
)
```

The transformation handles Unicode characters and removes all whitespace:

```ruby
# Unicode support
SimpleCommandDispatcher.call(
  command: 'café_command',
  command_namespace: 'api :: café :: v1'  # Spaces are removed
)
# Calls: Api::Café::V1::CaféCommand.call
```

### Dynamic Parameter Handling

The dispatcher intelligently handles different parameter types based on how your command initializer is coded:

```ruby
# Hash params → keyword arguments
def initialize(name:, email:)  # kwargs
  # Called with: YourCommand.call(name: 'John', email: 'john@example.com')
end

# Hash params → single hash argument
def initialize(params = {})    # single hash
  # Called with: YourCommand.call({name: 'John', email: 'john@example.com'})
end

# Array params → positional arguments
request_params: ['arg1', 'arg2', 'arg3']
# Called with: YourCommand.call('arg1', 'arg2', 'arg3')

# Single param → single argument
request_params: 'single_value'
# Called with: YourCommand.call('single_value')
```

### Payment Processing Example

```ruby
# app/commands/api/v1/payments/process.rb
class Api::V1::Payments::Process
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_payment_data
    return nil if errors.any?

    charge_card
  rescue StandardError => e
    errors.add(:payment, e.message)
    nil
  end

  private

  def initialize(params = {})
    @amount = params[:amount]
    @card_token = params[:card_token]
    @user_id = params[:user_id]
  end

  attr_reader :amount, :card_token, :user_id

  def validate_payment_data
    errors.add(:amount, 'must be positive') if amount.to_i <= 0
    errors.add(:card_token, 'is required') if card_token.blank?
    errors.add(:user_id, 'is required') if user_id.blank?
  end

  def charge_card
    PaymentProcessor.charge(
      amount: amount,
      card_token: card_token,
      user_id: user_id
    )
  end
end
```

**Route:** `POST /api/v1/payments/process` automatically calls `Api::V1::Payments::Process.call(params)`

### Custom Commands

You can create your own command classes without `CommandCallable`. Just ensure your command responds to the `.call` class method and returns whatever structure you need. The dispatcher will call your command and return the result - your convention, your rules.

## Error Handling

The dispatcher provides specific error classes for different failure scenarios:

```ruby
begin
  command = SimpleCommandDispatcher.call(
    command: 'NonExistentCommand',
    command_namespace: 'Api::V1'
  )
rescue SimpleCommandDispatcher::Errors::InvalidClassConstantError => e
  # Command class doesn't exist
  puts "Command not found: #{e.message}"
rescue SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError => e
  # Command class exists but doesn't have a .call method
  puts "Invalid command: #{e.message}"
rescue ArgumentError => e
  # Invalid arguments (empty command, wrong parameter types, etc.)
  puts "Invalid arguments: #{e.message}"
end
```

## Configuration

The gem can be configured in an initializer:

```ruby
# config/initializers/simple_command_dispatcher.rb
SimpleCommandDispatcher.configure do |config|
  # Configure the logger (defaults to Rails.logger in Rails apps, or Logger.new($stdout) otherwise)
  config.logger = Rails.logger

  # Or use a custom logger
  # config.logger = Logger.new('log/commands.log')
end
```

### Using Configuration in Commands

You can access the configured logger within your commands to add custom logging:

```ruby
class Api::V1::Payments::Process
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    logger.info("Processing payment for user #{user_id}")

    validate_payment_data
    return nil if errors.any?

    result = charge_card
    logger.info("Payment successful: #{result.inspect}")
    result
  rescue StandardError => e
    logger.error("Payment failed: #{e.message}")
    errors.add(:payment, e.message)
    nil
  end

  private

  def initialize(params = {})
    @amount = params[:amount]
    @card_token = params[:card_token]
    @user_id = params[:user_id]
  end

  attr_reader :amount, :card_token, :user_id

  def logger
    SimpleCommandDispatcher.configuration.logger
  end

  def validate_payment_data
    errors.add(:amount, 'must be positive') if amount.to_i <= 0
    errors.add(:card_token, 'is required') if card_token.blank?
    errors.add(:user_id, 'is required') if user_id.blank?
  end

  def charge_card
    PaymentProcessor.charge(
      amount: amount,
      card_token: card_token,
      user_id: user_id
    )
  end
end
```

### Debug Logging

The gem includes built-in debug logging that can be enabled using the `debug` option. This is useful for debugging command execution flow:

```ruby
# Enable debug logging for a single command
command = SimpleCommandDispatcher.call(
  command: :authenticate_user,
  command_namespace: '/api/v1',
  request_params: { email: 'user@example.com', password: 'secret' },
  options: { debug: true }
)

# Debug logging outputs:
# - Begin dispatching command (with command and namespace details)
# - Command to execute (the fully qualified class name)
# - Constantized command (the actual class constant)
# - End dispatching command
```

**Important:** Debug logging mode **does not** skip execution—it still runs your command and returns real results, but with detailed debug output to help you understand what's happening internally.

**Configure logging level:**

```ruby
# In your Rails initializer or application setup
SimpleCommandDispatcher.configure do |config|
  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG  # Set appropriate level
  config.logger = logger
end
```

## Migration from v3.x

If you're upgrading from v3.x, here are the key changes:

### Breaking Changes

1. **Method signature changed to keyword arguments:**

   ```ruby
   # v3.x (old)
   SimpleCommandDispatcher.call(:CreateUser, 'Api::V1', { options }, params)

   # v4.x (new)
   SimpleCommandDispatcher.call(
     command: :CreateUser,
     command_namespace: 'Api::V1',
     request_params: params
   )
   ```

2. **Removed simple_command dependency:**

   - Commands no longer need to include SimpleCommand
   - Commands must implement a `.call` class method
   - Return value is whatever your command returns (no automatic Result object)

3. **Removed configuration options:**

   - `allow_custom_commands` option removed (all commands are "custom" now)
   - Camelization options removed (always enabled)

4. **Namespace changes:**
   - Error classes: `SimpleCommand::Dispatcher::Errors::*` → `SimpleCommandDispatcher::Errors::*`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gangelo/simple_command_dispatcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Documentation

For comprehensive documentation, examples, and guides, visit the **[Wiki](https://github.com/gangelo/simple_command_dispatcher/wiki)**:

- **[Quick Start Tutorial](https://github.com/gangelo/simple_command_dispatcher/wiki/Quick-Start)** - Build your first command in 5 minutes
- **[Core Concepts](https://github.com/gangelo/simple_command_dispatcher/wiki/Core-Concepts)** - Understand how SCD works
- **[Creating Commands](https://github.com/gangelo/simple_command_dispatcher/wiki/Creating-Commands)** - Learn to write command classes
- **[CommandCallable Module](https://github.com/gangelo/simple_command_dispatcher/wiki/CommandCallable-Module)** - Master command standardization
- **[Dynamic Dispatching](https://github.com/gangelo/simple_command_dispatcher/wiki/Dynamic-Dispatching)** - Advanced controller patterns
- **[Route-to-Command Mapping](https://github.com/gangelo/simple_command_dispatcher/wiki/Route-to-Command-Mapping)** - Convention over configuration explained
- **[Real-World Examples](https://github.com/gangelo/simple_command_dispatcher/wiki/Examples-Authentication)** - Authentication, payments, search, and more
- **[Parameter Handling](https://github.com/gangelo/simple_command_dispatcher/wiki/Parameter-Handling)** - Working with different parameter types
- **[Error Handling](https://github.com/gangelo/simple_command_dispatcher/wiki/Error-Handling)** - Validation and error management
- **[FAQ](https://github.com/gangelo/simple_command_dispatcher/wiki/FAQ)** - Frequently asked questions
- **[Installation](https://github.com/gangelo/simple_command_dispatcher/wiki/Installation)** - Complete setup guide

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and breaking changes.

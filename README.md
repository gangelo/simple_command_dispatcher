[![Ruby](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml/badge.svg?refresh=6)](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml)
[![GitHub version](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher.svg?refresh=6)](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher)
[![Gem Version](https://badge.fury.io/rb/simple_command_dispatcher.svg?refresh=6)](https://badge.fury.io/rb/simple_command_dispatcher)
[![](https://ruby-gem-downloads-badge.herokuapp.com/simple_command_dispatcher?type=total)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/simple_command_dispatcher/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

# simple_command_dispatcher

## Overview

**simple_command_dispatcher** (SCD) allows your Rails or Rails API application to _dynamically_ call backend command services from your Rails controller actions using a flexible, convention-over-configuration approach.

## Features

- 🚀 **Dynamic Command Dispatch**: Call command classes by name with flexible namespacing
- 🔄 **Automatic Camelization**: Converts RESTful routes to Ruby constants automatically
- 🌐 **Unicode Support**: Handles Unicode characters and whitespace properly
- 🎯 **Multiple Input Formats**: Accepts strings, arrays, hashes for commands and namespaces
- ⚡ **Performance Optimized**: Uses Rails' proven camelization methods for speed
- 🔧 **Flexible Parameters**: Supports Hash, Array, and single object parameters
- 📦 **No Dependencies**: Removed simple_command dependency for lighter footprint

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

- Ruby >= 3.1.0
- Rails (optional, but optimized for Rails applications)

## Basic Usage

### Simple Command Dispatch

```ruby
# Basic command call
result = SimpleCommandDispatcher.call(
  command: 'AuthenticateUser',
  command_namespace: 'Api::V1',
  request_params: { email: 'user@example.com', password: 'secret' }
)

# This calls: Api::V1::AuthenticateUser.call(email: 'user@example.com', password: 'secret')
```

### Automatic Camelization

Command names and namespaces are automatically camelized using optimized RESTful route conversion, allowing flexible input formats:

```ruby
# All of these are equivalent and call: Api::UserSessions::V1::CreateCommand.call

# Lowercase strings with various separators
SimpleCommandDispatcher.call(
  command: 'create_command',
  command_namespace: 'api::user_sessions::v1'
)

# Mixed case array
SimpleCommandDispatcher.call(
  command: :CreateCommand,
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

The camelization handles Unicode characters and removes all whitespace (including Unicode whitespace):

```ruby
# Unicode support
SimpleCommandDispatcher.call(
  command: 'café_command',
  command_namespace: 'api :: café :: v1'  # Spaces are removed
)
# Calls: Api::Café::V1::CaféCommand.call
```

### Parameter Handling

The dispatcher supports multiple parameter formats:

```ruby
# Hash parameters (passed as keyword arguments)
SimpleCommandDispatcher.call(
  command: 'CreateUser',
  command_namespace: 'Api::V1',
  request_params: { name: 'John', email: 'john@example.com' }
)
# Calls: Api::V1::CreateUser.call(name: 'John', email: 'john@example.com')

# Array parameters (passed as positional arguments)
SimpleCommandDispatcher.call(
  command: 'ProcessData',
  command_namespace: 'Services',
  request_params: ['data1', 'data2', 'data3']
)
# Calls: Services::ProcessData.call('data1', 'data2', 'data3')

# Single parameter
SimpleCommandDispatcher.call(
  command: 'SendEmail',
  command_namespace: 'Mailers',
  request_params: 'user@example.com'
)
# Calls: Mailers::SendEmail.call('user@example.com')

# No parameters
SimpleCommandDispatcher.call(
  command: 'HealthCheck',
  command_namespace: 'System'
)
# Calls: System::HealthCheck.call
```

## Rails Integration Example

Here's a comprehensive example showing how to integrate SCD with a Rails API application:

### Application Controller

```ruby
# app/controllers/application_controller.rb
require 'simple_command_dispatcher'

class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  protected

  def get_command_namespace
    # Extract namespace from request path: "/api/my_app/v1/users" → "api/my_app/v1"
    path_segments = request.path.split('/').reject(&:empty?)
    path_segments.take(3).join('/')
  end

  private

  def authenticate_request
    result = SimpleCommandDispatcher.call(
      command: 'AuthenticateRequest',
      command_namespace: get_command_namespace,
      request_params: { headers: request.headers }
    )

    if result.success?
      @current_user = result.user
    else
      render json: { error: 'Not Authorized' }, status: 401
    end
  end
end
```

### Controller Actions

```ruby
# app/controllers/api/my_app/v1/users_controller.rb
class Api::MyApp::V1::UsersController < ApplicationController
  def create
    result = SimpleCommandDispatcher.call(
      command: 'CreateUser',
      command_namespace: get_command_namespace,
      request_params: user_params
    )

    if result.success?
      render json: result.user, status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    result = SimpleCommandDispatcher.call(
      command: 'UpdateUser',
      command_namespace: get_command_namespace,
      request_params: { id: params[:id], **user_params }
    )

    if result.success?
      render json: result.user
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone)
  end
end
```

### Command Classes

```ruby
# app/commands/api/my_app/v1/authenticate_request.rb
module Api
  module MyApp
    module V1
      class AuthenticateRequest
        def self.call(headers:)
          new(headers: headers).call
        end

        def initialize(headers:)
          @headers = headers
        end

        def call
          user = authenticate_with_token
          if user
            OpenStruct.new(success?: true, user: user)
          else
            OpenStruct.new(success?: false, errors: ['Invalid token'])
          end
        end

        private

        attr_reader :headers

        def authenticate_with_token
          token = headers['Authorization']&.gsub('Bearer ', '')
          return nil unless token

          # Your authentication logic here
          User.find_by(auth_token: token)
        end
      end
    end
  end
end
```

```ruby
# app/commands/api/my_app/v1/create_user.rb
module Api
  module MyApp
    module V1
      class CreateUser
        def self.call(**params)
          new(**params).call
        end

        def initialize(name:, email:, phone: nil)
          @name = name
          @email = email
          @phone = phone
        end

        def call
          user = User.new(name: name, email: email, phone: phone)

          if user.save
            OpenStruct.new(success?: true, user: user)
          else
            OpenStruct.new(success?: false, errors: user.errors.full_messages)
          end
        end

        private

        attr_reader :name, :email, :phone
      end
    end
  end
end
```

### Autoloading Commands

To ensure your command classes are properly loaded:

```ruby
# config/initializers/simple_command_dispatcher.rb

# Autoload command classes
Rails.application.config.to_prepare do
  commands_path = Rails.root.join('app', 'commands')

  if commands_path.exist?
    Dir[commands_path.join('**', '*.rb')].each do |file|
      require_dependency file
    end
  end
end
```

## Error Handling

The dispatcher provides specific error classes for different failure scenarios:

```ruby
begin
  result = SimpleCommandDispatcher.call(
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

## Advanced Usage

### Route-Based Command Dispatch

For RESTful APIs, you can map routes directly to commands:

```ruby
# Extract command from route
def dispatch_from_route
  # Route: "/api/my_app/v1/users/create"
  path_segments = request.path.split('/').reject(&:empty?)

  namespace = path_segments.take(3).join('/')     # "api/my_app/v1"
  command = path_segments.last                    # "create"

  SimpleCommandDispatcher.call(
    command: "#{command}_#{controller_name.singularize}",  # "create_user"
    command_namespace: namespace,
    request_params: request_params
  )
end
```

### Dynamic API Versioning

```ruby
# Handle multiple API versions dynamically
def call_versioned_command(command_name, version = 'v1')
  SimpleCommandDispatcher.call(
    command: command_name,
    command_namespace: ['api', app_name, version],
    request_params: request_params
  )
end

# Usage
result = call_versioned_command('authenticate_user', 'v2')
```

### Batch Command Execution

```ruby
# Execute multiple related commands
def process_user_registration(user_data)
  commands = [
    { command: 'validate_user', params: user_data },
    { command: 'create_user', params: user_data },
    { command: 'send_welcome_email', params: { email: user_data[:email] } }
  ]

  results = commands.map do |cmd|
    SimpleCommandDispatcher.call(
      command: cmd[:command],
      command_namespace: 'user_registration',
      request_params: cmd[:params]
    )
  end

  # Check if all commands succeeded
  if results.all?(&:success?)
    { success: true, user: results[1].user }
  else
    { success: false, errors: results.map(&:errors).flatten.compact }
  end
end
```

## Configuration

The gem can be configured in an initializer:

```ruby
# config/initializers/simple_command_dispatcher.rb
SimpleCommandDispatcher.configure do |config|
  # Configuration options will be added in future versions
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

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and breaking changes.

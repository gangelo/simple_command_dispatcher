# Core Concepts

Understanding these core concepts will help you master simple_command_dispatcher (SCD).

## 1. Convention Over Configuration

The core idea: **Your route path IS your command name**. No configuration needed.

### How It Works

```ruby
# Your request path:
"/api/v1/users/authenticate"

# SCD automatically calls:
Api::V1::Users::Authenticate.call(params)
```

That's it! SCD transforms the path into a Ruby class constant and calls it.

### The Transformation (Behind the Scenes)

```ruby
"/api/v1/users/authenticate"  # Input path
↓
['api', 'v1', 'users', 'authenticate']  # Split into parts
↓
['Api', 'V1', 'Users', 'Authenticate']  # Camelize each part
↓
Api::V1::Users::Authenticate  # Join with ::
```

This happens automatically—you never think about it.

## 2. The Command Pattern

SCD implements the **Command Pattern** - encapsulating requests as objects.

### Basic Command Structure

Every command needs:

1. A `.call` class method (automatically added by `CommandCallable`)
2. An `initialize` method to accept parameters
3. A `call` instance method that performs the work

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Your business logic here
    do_something
  end

  private

  def initialize(params = {})
    @param1 = params[:param1]
    @param2 = params[:param2]
  end

  attr_reader :param1, :param2

  def do_something
    # Implementation
  end
end
```

### Why Commands?

Commands provide several benefits:

- **Encapsulation**: Business logic is isolated in a single class
- **Testability**: Easy to test in isolation
- **Reusability**: Commands can be called from anywhere
- **Single Responsibility**: Each command does one thing well
- **Composability**: Commands can call other commands

## 3. The CommandCallable Module

`CommandCallable` is an optional module that standardizes command interfaces.

### What It Provides

When you prepend `CommandCallable`:

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Your logic
  end
end
```

You automatically get:

1. **Class Method**: `.call` that instantiates and executes the command
2. **Result Tracking**: `@result` attribute storing the return value
3. **Success/Failure Methods**: `success?` and `failure?`
4. **Error Handling**: `errors` collection for validation errors
5. **Call Tracking**: Internal `@called` flag

### Important: Understanding the Return Value

When you call a command, you get back **the command object itself**, not the result directly:

```ruby
command = MyCommand.call(param1: 'value')

# The command object has everything you need:
command.result    # The actual return value from your call method
command.success?  # true if no errors
command.failure?  # true if errors exist
command.errors    # Hash of errors (if any)
```

**Why?** This lets you check success AND get the result from the same object:

```ruby
if command.success?
  user = command.result
  render json: { user: user }
else
  render json: { errors: command.errors }, status: :unprocessable_entity
end
```

## 4. Parameter Handling

SCD intelligently handles different parameter types based on your initializer signature.

### Hash Parameters (Most Common)

```ruby
# Your command expects a hash
def initialize(params = {})
  @email = params[:email]
  @password = params[:password]
end

# Called with hash
MyCommand.call(email: 'user@example.com', password: 'secret')
# Or
SimpleCommandDispatcher.call(
  command: :my_command,
  request_params: { email: 'user@example.com', password: 'secret' }
)
```

### Keyword Arguments

```ruby
# Your command expects keyword arguments
def initialize(email:, password:)
  @email = email
  @password = password
end

# Called with hash (automatically converts to kwargs)
MyCommand.call(email: 'user@example.com', password: 'secret')
```

### Array Parameters

```ruby
# Your command expects positional arguments
def initialize(arg1, arg2, arg3)
  @arg1 = arg1
  @arg2 = arg2
  @arg3 = arg3
end

# Called with array
SimpleCommandDispatcher.call(
  command: :my_command,
  request_params: ['value1', 'value2', 'value3']
)
```

### Single Parameter

```ruby
# Your command expects a single value
def initialize(value)
  @value = value
end

# Called with single value
SimpleCommandDispatcher.call(
  command: :my_command,
  request_params: 'single_value'
)
```

## 5. Error Handling

Commands track errors using a built-in error collection.

### Adding Errors

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_data
    return nil if errors.any?

    process_data
  end

  private

  def validate_data
    errors.add(:email, 'is required') if email.blank?
    errors.add(:email, 'is invalid') unless email.match?(/\A[^@]+@[^@]+\z/)
    errors.add(:password, 'is too short') if password.length < 8
  end

  def process_data
    # Your logic
  end
end
```

### Error Structure

Errors are stored as a hash with field names as keys:

```ruby
{
  email: ['is required', 'is invalid'],
  password: ['is too short']
}
```

### Getting Error Messages

```ruby
command = MyCommand.call(email: '', password: '123')

command.errors.full_messages
# => ['Email is required', 'Email is invalid', 'Password is too short']

# Or access by field
command.errors[:email]
# => ['is required', 'is invalid']
```

## 6. Namespacing

Commands can be organized into namespaces that match your application structure.

### Simple Namespace

```ruby
# Command: app/commands/users/create.rb
module Users
  class Create
    # ...
  end
end

# Call it
SimpleCommandDispatcher.call(
  command: :create,
  command_namespace: :users
)
```

### Deep Namespace (API Versioning)

```ruby
# Command: app/commands/api/v1/users/create.rb
module Api
  module V1
    module Users
      class Create
        # ...
      end
    end
  end
end

# Call it
SimpleCommandDispatcher.call(
  command: :create,
  command_namespace: 'api/v1/users'
)

# Or from request path
SimpleCommandDispatcher.call(
  command: '/api/v1/users/create'  # namespace included in command
)
```

### Namespace Formats

SCD accepts namespaces in multiple formats:

```ruby
# String with ::
command_namespace: 'Api::V1::Users'

# String with /
command_namespace: 'api/v1/users'

# Array
command_namespace: [:api, :v1, :users]

# Hash (self-documenting)
command_namespace: { api: :Api, version: :V1, resource: :Users }
```

All produce the same result: `Api::V1::Users::`

## 7. The Dispatcher API

The main entry point is `SimpleCommandDispatcher.call`:

### Method Signature

```ruby
SimpleCommandDispatcher.call(
  command:,              # Required: String, Symbol, or Array
  command_namespace: {}, # Optional: String, Symbol, Array, or Hash
  request_params: nil,   # Optional: Hash, Array, or single value
  options: {}            # Optional: Hash (e.g., { debug: true })
)
```

### Parameters

**command** (required)
- The command name or full path
- Accepts: String, Symbol, Array
- Examples: `:create_user`, `'/api/v1/users/create'`, `['Create', 'User']`

**command_namespace** (optional)
- The namespace for the command
- Accepts: String, Symbol, Array, Hash
- Default: `{}`
- Examples: `'Api::V1'`, `[:api, :v1]`, `{ api: :Api, version: :V1 }`

**request_params** (optional)
- Parameters passed to the command's initializer
- Accepts: Hash, Array, or single value
- Default: `nil`
- Most commonly a Hash from Rails `params`

**options** (optional)
- Execution options
- Accepts: Hash
- Default: `{}`
- Currently supported: `{ debug: true }` for debug logging

## 8. Debug Mode

Enable debug logging to see what's happening under the hood:

```ruby
command = SimpleCommandDispatcher.call(
  command: :authenticate_user,
  command_namespace: '/api/v1',
  request_params: { email: 'user@example.com' },
  options: { debug: true }
)
```

Debug output includes:

```
[DEBUG] Begin dispatching command...
[DEBUG] Command: authenticate_user
[DEBUG] Namespace: /api/v1
[DEBUG] Command to execute: Api::V1::AuthenticateUser
[DEBUG] Constantized command: Api::V1::AuthenticateUser (class)
[DEBUG] End dispatching command
```

This helps troubleshoot routing and transformation issues.

## 9. Configuration

Configure the gem in an initializer:

```ruby
# config/initializers/simple_command_dispatcher.rb
SimpleCommandDispatcher.configure do |config|
  config.logger = Rails.logger
end
```

### Default Behavior

If no configuration is provided:

- In Rails apps: Uses `Rails.logger` automatically
- In non-Rails apps: Uses `Logger.new($stdout)`

### Custom Logger

```ruby
SimpleCommandDispatcher.configure do |config|
  logger = Logger.new('log/commands.log')
  logger.level = Logger::DEBUG
  config.logger = logger
end
```

## Summary

These core concepts form the foundation of simple_command_dispatcher:

1. **Convention Over Configuration** - Automatic route-to-command mapping
2. **Command Pattern** - Encapsulated, testable business logic
3. **CommandCallable Module** - Standardized command interface
4. **Parameter Handling** - Flexible parameter types
5. **Error Handling** - Built-in error tracking
6. **Namespacing** - Organized command structure
7. **Dispatcher API** - Simple, consistent interface
8. **Debug Mode** - Visibility into execution flow
9. **Configuration** - Customizable logging

Master these concepts and you'll be able to leverage SCD effectively in your applications!

## Next Steps

- [Create your first command](Creating-Commands.md)
- [Learn about CommandCallable in depth](CommandCallable-Module.md)
- [Explore real-world examples](Examples-Authentication.md)

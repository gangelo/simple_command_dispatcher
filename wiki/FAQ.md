# Frequently Asked Questions

Common questions and answers about simple_command_dispatcher.

## General Questions

### What is simple_command_dispatcher?

SCD automatically maps your request paths to Ruby commands. No configuration needed.

```ruby
POST /api/v1/users/create  →  Api::V1::Users::Create.call(params)
```

That's the whole idea!

### Do I need Rails?

No! It works with any Ruby app. You just need ActiveSupport >= 7.0.8.

### Is this production-ready?

Yes! 100% test coverage, actively maintained, and battle-tested in production.

### How is it different from other command gems?

Most gems require explicit routing:
```ruby
case action
when 'create' then CreateUser.call
when 'update' then UpdateUser.call
end
```

SCD uses convention:
```ruby
SimpleCommandDispatcher.call(command: request.path, request_params: params)
```

One line handles all actions!

## Installation & Setup

### What Ruby version do I need?

Ruby >= 3.3.0 and < 4.0.

### Can I use this with Rails 8?

Yes! SCD is compatible with Rails 7 and 8.

### Do I need to configure anything?

No configuration is required. By default, SCD uses `Rails.logger` in Rails apps or `Logger.new($stdout)` in non-Rails apps.

### Where should I put my command files?

Create them in `app/commands/` with a directory structure matching your namespaces:

```
app/commands/
├── api/
│   ├── v1/
│   │   ├── users/
│   │   │   ├── create.rb
│   │   │   └── authenticate.rb
│   │   └── posts/
│   │       └── search.rb
```

## Using Commands

### Do I have to use the CommandCallable module?

No, it's optional. But it's highly recommended because it provides:
- Automatic `.call` class method
- Success/failure tracking
- Error collection
- Result storage
- Standardized interface

### Why does `.call` return the command instance instead of the result?

Because you need THREE things, not just one:

```ruby
command = MyCommand.call(params)

# 1. Did it work?
command.success?  # true/false

# 2. What's the result?
command.result  # The actual return value

# 3. What went wrong?
command.errors  # Hash of errors
```

Returning the command object gives you all three!

### How do I access the actual result?

Use the `.result` method:

```ruby
command = MyCommand.call
command.result  # The return value from your call method
```

### Can commands return different types of values?

Yes! Commands can return anything:
- ActiveRecord objects
- Collections
- Hashes
- Arrays
- Booleans
- nil
- Custom objects

### How do I make initialize private?

Just put it after the `private` keyword:

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # logic
  end

  private  # Everything below is private

  def initialize(params = {})
    @params = params
  end
end
```

## Route Mapping

### How does path-to-command mapping work?

SCD transforms routes using these steps:
1. Normalize separators (/, -, ., ::, spaces)
2. Split into segments
3. Camelize each segment
4. Join with `::`
5. Constantize

Example: `/api/v1/users/create` → `Api::V1::Users::Create`

### What separators are supported?

All of these:
- `/` (forward slash)
- `::` (double colon)
- `-` (hyphen)
- `.` (dot)
- Spaces (removed)

You can even mix them!

### Are routes case-sensitive?

No. SCD normalizes case:
- `'api'` → `'Api'`
- `'API'` → `'Api'`
- `'Api'` → `'Api'`

### Can I use Unicode characters?

Yes! Unicode characters are preserved, and Unicode whitespace is removed:

```ruby
'café_command' → 'CaféCommand'
```

## Parameters

### How do I pass parameters to commands?

Use the `request_params` argument:

```ruby
SimpleCommandDispatcher.call(
  command: :my_command,
  request_params: { email: 'user@example.com', password: 'secret' }
)
```

### What parameter types are supported?

- **Hash** (most common): `{ key: 'value' }`
- **Array**: `['arg1', 'arg2', 'arg3']`
- **Single value**: `'value'`
- **nil**: No parameters

### How does SCD know whether to use keyword arguments or a hash?

SCD checks your initializer signature:

```ruby
# Keyword arguments
def initialize(email:, password:)
  # Called with: command.call(email: 'x', password: 'y')
end

# Hash parameter
def initialize(params = {})
  # Called with: command.call({email: 'x', password: 'y'})
end
```

## Error Handling

### How do I add validation errors?

Use the `errors` object:

```ruby
def call
  errors.add(:email, 'is required') if email.blank?
  errors.add(:email, 'is invalid') unless valid_email?

  return nil if errors.any?

  # Process...
end
```

### How do I check if a command succeeded?

Use `success?` and `failure?`:

```ruby
command = MyCommand.call

if command.success?
  # No errors
else
  # Has errors
end
```

### What's the difference between success? and failure?

- `success?` returns `true` if the command was called and has no errors
- `failure?` returns `true` if the command was called and has errors

Both return `false` if the command hasn't been called yet.

### How do I get formatted error messages?

Use `full_messages`:

```ruby
command.errors.full_messages
# => ['Email is required', 'Email is invalid', 'Password is too short']
```

### Can I add errors from other commands?

Yes, use `add_multiple_errors`:

```ruby
other_command = OtherCommand.call
if other_command.failure?
  errors.add_multiple_errors(other_command.errors)
end
```

## Dynamic Dispatching

### What is dynamic dispatching?

It's using `request.path` to automatically route to the correct command without explicit code:

```ruby
SimpleCommandDispatcher.call(
  command: request.path,  # "/api/v1/users/search"
  request_params: params
)
# Automatically calls: Api::V1::Users::Search.call(params)
```

### Do I need to write code for each action?

No! You can use a `before_action` to handle all actions:

```ruby
class UsersController < ApplicationController
  before_action :route_request

  def search; end  # Empty - routing handled by before_action
  def create; end
  def update; end

  private

  def route_request
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: params
    )
    # Handle response...
  end
end
```

### Can I mix standard actions and dispatched actions?

Yes:

```ruby
class UsersController < ApplicationController
  before_action :route_request, except: [:index, :show]

  def index
    # Standard action
  end

  def show
    # Standard action
  end

  def search; end  # Dispatched
  def filter; end  # Dispatched
end
```

## Versioning

### How do I handle multiple API versions?

Use namespaces:

```ruby
# app/commands/api/v1/users/search.rb
module Api::V1::Users
  class Search
    # V1 logic
  end
end

# app/commands/api/v2/users/search.rb
module Api::V2::Users
  class Search
    # V2 logic
  end
end
```

Requests automatically route to the correct version:
- `/api/v1/users/search` → `Api::V1::Users::Search`
- `/api/v2/users/search` → `Api::V2::Users::Search`

## Debugging

### How do I see what command is being called?

Enable debug mode:

```ruby
SimpleCommandDispatcher.call(
  command: :my_command,
  request_params: params,
  options: { debug: true }
)
```

### What's logged in debug mode?

- Begin/end markers
- Command name
- Namespace
- Fully qualified class name
- Constantized command class

### Does debug mode affect execution?

No! It just adds logging. The command still runs normally and returns real results.

### Where do debug logs go?

To the configured logger:
- Rails apps: `Rails.logger` (usually `log/development.log`)
- Non-Rails apps: `Logger.new($stdout)` (console)

## Testing

### How do I test commands?

Commands are easy to test in isolation:

```ruby
RSpec.describe MyCommand do
  describe '#call' do
    subject(:command) { described_class.call(params) }

    context 'with valid params' do
      let(:params) { { email: 'test@example.com' } }

      it 'succeeds' do
        expect(command.success?).to be true
      end

      it 'returns the expected result' do
        expect(command.result).to eq('expected')
      end
    end

    context 'with invalid params' do
      let(:params) { { email: '' } }

      it 'fails' do
        expect(command.failure?).to be true
      end

      it 'includes errors' do
        expect(command.errors[:email]).to include('is required')
      end
    end
  end
end
```

### Do I need to test the dispatcher itself?

No. The dispatcher is thoroughly tested. Just test your command logic.

### Can I mock commands in controller tests?

Yes:

```ruby
allow(SimpleCommandDispatcher).to receive(:call).and_return(mock_command)
```

## Performance

### Is there significant overhead?

No. SCD uses Rails' proven `camelize` methods and caches constantized classes. The overhead is minimal compared to your command logic.

### Should I worry about performance?

Not for typical use cases. The transformation and constantization happen once per request, which is negligible compared to database queries and business logic.

### Does debug mode slow things down?

Slightly, due to additional logging. Only enable it in development or when troubleshooting.

## Common Issues

### "InvalidClassConstantError: is not a valid class constant"

**Cause:** The command class doesn't exist.

**Solution:**
1. Check the file exists: `app/commands/api/v1/my_command.rb`
2. Check the class is defined: `Api::V1::MyCommand`
3. Check namespaces match: Module names must match directory structure
4. Restart your server (for autoloading issues)

### "RequiredClassMethodMissingError: does not respond_to? class method 'call'"

**Cause:** Your command class doesn't have a `.call` class method.

**Solution:** Prepend `CommandCallable`:

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable
  # ...
end
```

### "private method `new' called"

**Cause:** You made `initialize` private and tried to call `MyCommand.new` directly.

**Solution:** Use `MyCommand.call` instead:

```ruby
# Wrong
MyCommand.new(params)

# Correct
MyCommand.call(params)
```

### Command returns nil but no errors

**Check:**
1. Did your `call` method explicitly return a value?
2. Did you forget to return after validation?

```ruby
# Wrong
def call
  validate
  process_data  # Implicit return - might be nil
end

# Correct
def call
  validate
  return nil if errors.any?

  process_data  # Explicit return value
end
```

## Best Practices

### Should I always use CommandCallable?

Yes, unless you have a specific reason not to. It provides a standardized interface and helpful features.

### Should initialize be private?

Yes! This enforces proper usage through the `.call` class method.

### How should I organize commands?

Match your namespace structure:

```
app/commands/
└── api/
    └── v1/
        ├── users/
        ├── posts/
        └── comments/
```

### One command per file?

Yes. Follow the Rails convention: one class per file, matching the file name.

### Should commands call other commands?

Yes, commands can compose other commands. This is a great pattern for complex workflows.

## Migration

### I'm using v3.x. Should I upgrade?

Yes! v4.x has better APIs, improved error handling, and removes the dependency on the `simple_command` gem.

### Is migration difficult?

No. The main change is using keyword arguments. See the [Migration Guide](Migration-Guide.md).

### Can I run both versions?

No. Choose one version. v4.x is recommended for new projects.

## Getting Help

### Where can I get more help?

- **Documentation:** [GitHub Wiki](https://github.com/gangelo/simple_command_dispatcher/wiki)
- **Issues:** [GitHub Issues](https://github.com/gangelo/simple_command_dispatcher/issues)
- **Examples:** [Demo App](https://github.com/gangelo/simple_command_dispatcher_demo_app)
- **API Docs:** [RubyDoc](http://www.rubydoc.info/gems/simple_command_dispatcher/)

### How do I report a bug?

[Open an issue on GitHub](https://github.com/gangelo/simple_command_dispatcher/issues) with:
- Ruby version
- Rails version (if applicable)
- simple_command_dispatcher version
- Code example
- Error message
- Expected vs actual behavior

### Can I contribute?

Yes! Bug reports and pull requests are welcome. See [Contributing](https://github.com/gangelo/simple_command_dispatcher#contributing).

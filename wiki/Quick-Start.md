# Quick Start Tutorial

Get up and running with simple_command_dispatcher in just 5 minutes!

## Prerequisites

- Ruby >= 3.3.0
- Rails application (or any Ruby project with ActiveSupport)

## Step 1: Install the Gem

Add to your `Gemfile`:

```ruby
gem 'simple_command_dispatcher'
```

Then run:

```bash
bundle install
```

## Step 2: Create Your First Command

Create a simple greeting command in `app/commands/greet_user.rb`:

```ruby
class GreetUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Hello, #{name}!"
  end

  private

  def initialize(params = {})
    @name = params[:name]
  end

  attr_reader :name
end
```

**That's it!** The `CommandCallable` module gives you success tracking, error handling, and a `.call` class method automatically.

## Step 3: Call Your Command

Call it directly:

```ruby
command = GreetUser.call(name: 'Alice')
command.success?  # => true
command.result    # => "Hello, Alice!"
```

Or use the dispatcher:

```ruby
command = SimpleCommandDispatcher.call(
  command: :greet_user,
  request_params: { name: 'Alice' }
)

command.result  # => "Hello, Alice!"
```

Both ways work exactly the same!

## Step 4: Use It in a Controller

Add it to a Rails controller:

```ruby
# app/controllers/greetings_controller.rb
class GreetingsController < ApplicationController
  def create
    command = GreetUser.call(params)

    if command.success?
      render json: { message: command.result }
    else
      render json: { errors: command.errors }, status: :unprocessable_entity
    end
  end
end
```

Add a route and test:

```ruby
# config/routes.rb
post '/greet', to: 'greetings#create'
```

```bash
curl -X POST http://localhost:3000/greet -H "Content-Type: application/json" -d '{"name":"Alice"}'

# Response: {"message":"Hello, Alice!"}
```

## Step 5: Add Validation

Let's make our command more robust with validation:

```ruby
# app/commands/greet_user.rb
class GreetUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_name
    return nil if errors.any?

    "Hello, #{name}! Welcome to simple_command_dispatcher."
  end

  private

  def initialize(params = {})
    @name = params[:name]
  end

  attr_reader :name

  def validate_name
    errors.add(:name, 'is required') if name.blank?
    errors.add(:name, 'must be at least 2 characters') if name.present? && name.length < 2
  end
end
```

Now test with invalid data:

```bash
curl -X POST http://localhost:3000/greet \
  -H "Content-Type: application/json" \
  -d '{"name": ""}'

# Response: {"errors":{"name":["is required"]}}
```

## Step 6: The Real Magic - Convention Over Configuration

Here's where SCD shines. Create a namespaced command:

```ruby
# app/commands/api/v1/greet_user.rb
module Api
  module V1
    class GreetUser
      prepend SimpleCommandDispatcher::Commands::CommandCallable

      def call
        errors.add(:name, 'is required') if name.blank?
        return nil if errors.any?

        "Hello, #{name}! (API v1)"
      end

      private

      def initialize(params = {})
        @name = params[:name]
      end

      attr_reader :name
    end
  end
end
```

Now the magic—use `request.path` to automatically route to the right command:

```ruby
# app/controllers/api/v1/greetings_controller.rb
module Api
  module V1
    class GreetingsController < ApplicationController
      def create
        # This ONE line handles routing!
        command = SimpleCommandDispatcher.call(
          command: request.path,  # "/api/v1/greet_user"
          request_params: params
        )

        if command.success?
          render json: { message: command.result }
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

**What just happened?**
The request path `/api/v1/greet_user` automatically mapped to `Api::V1::GreetUser.call(params)`

No manual routing. No case statements. Pure convention!

## What You've Learned

In just 5 minutes, you've learned how to:

1. Install and set up simple_command_dispatcher
2. Create command classes with `CommandCallable`
3. Use commands in Rails controllers
4. Add validation and error handling
5. Use convention over configuration for dynamic dispatching

## Next Steps

- [Learn more about CommandCallable](CommandCallable-Module.md)
- [Master parameter handling](Parameter-Handling.md)
- [Explore real-world examples](Examples-Authentication.md)
- [Understand route-to-command mapping](Route-to-Command-Mapping.md)

# Parameter Handling

Master how simple_command_dispatcher handles different parameter types and passes them to your commands.

## Overview

SCD intelligently adapts parameter passing based on your command's initializer signature. You don't need to configure anything—it just works!

## Parameter Types

### Hash Parameters (Most Common)

Hash parameters are the most common type, typically from Rails `params`:

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.create!(email: email, password: password, name: name)
  end

  private

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
    @name = params[:name]
  end

  attr_reader :email, :password, :name
end

# Usage
SimpleCommandDispatcher.call(
  command: :create_user,
  request_params: { email: 'alice@example.com', password: 'secret', name: 'Alice' }
)
```

### Keyword Arguments

If your initializer uses keyword arguments, SCD automatically converts hash parameters:

```ruby
class AuthenticateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Authenticate logic
  end

  private

  def initialize(email:, password:)
    @email = email
    @password = password
  end

  attr_reader :email, :password
end

# Usage - same hash syntax!
SimpleCommandDispatcher.call(
  command: :authenticate_user,
  request_params: { email: 'alice@example.com', password: 'secret' }
)
# SCD automatically converts to keyword arguments
```

### Array Parameters

Pass multiple positional arguments as an array:

```ruby
class CalculateDistance
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
  end

  private

  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end

  attr_reader :x1, :y1, :x2, :y2
end

# Usage
SimpleCommandDispatcher.call(
  command: :calculate_distance,
  request_params: [0, 0, 3, 4]  # Passed as positional arguments
)
# Calls: CalculateDistance.new(0, 0, 3, 4)
```

### Single Value Parameter

Pass a single non-hash, non-array value:

```ruby
class FindUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.find(user_id)
  end

  private

  def initialize(user_id)
    @user_id = user_id
  end

  attr_reader :user_id
end

# Usage
SimpleCommandDispatcher.call(
  command: :find_user,
  request_params: 123  # Passed as single argument
)
# Calls: FindUser.new(123)
```

### No Parameters

Commands can accept no parameters:

```ruby
class GetAllUsers
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.all
  end

  private

  def initialize
    # No parameters needed
  end
end

# Usage
SimpleCommandDispatcher.call(command: :get_all_users)
# Or
SimpleCommandDispatcher.call(command: :get_all_users, request_params: nil)
```

## Rails Integration

### Using params in Controllers

In Rails controllers, pass the `params` hash directly:

```ruby
class UsersController < ApplicationController
  def create
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: params  # Full Rails params hash
    )

    if command.success?
      render json: { user: command.result }, status: :created
    else
      render json: { errors: command.errors }, status: :unprocessable_entity
    end
  end
end
```

### Strong Parameters

Use strong parameters for security:

```ruby
class UsersController < ApplicationController
  def create
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: user_params  # Permitted params only
    )

    handle_response(command)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end
end
```

### Merging Additional Parameters

Add extra context to params:

```ruby
def create
  command = SimpleCommandDispatcher.call(
    command: request.path,
    request_params: user_params.merge(
      current_user: current_user,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  )

  handle_response(command)
end
```

## Advanced Patterns

### Optional Parameters with Defaults

```ruby
class SearchUsers
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.where("name ILIKE ?", "%#{query}%")
        .limit(limit)
        .offset(offset)
  end

  private

  def initialize(params = {})
    @query = params[:query] || ''
    @limit = params[:limit] || 10
    @offset = params[:offset] || 0
  end

  attr_reader :query, :limit, :offset
end
```

### Required vs Optional Parameters

```ruby
class CreatePost
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_required_params
    return nil if errors.any?

    Post.create!(
      title: title,
      body: body,
      author: author,
      tags: tags,          # Optional
      published: published  # Optional
    )
  end

  private

  def initialize(params = {})
    # Required
    @title = params[:title]
    @body = params[:body]
    @author = params[:author]

    # Optional with defaults
    @tags = params[:tags] || []
    @published = params[:published] || false
  end

  attr_reader :title, :body, :author, :tags, :published

  def validate_required_params
    errors.add(:title, 'is required') if title.blank?
    errors.add(:body, 'is required') if body.blank?
    errors.add(:author, 'is required') if author.blank?
  end
end
```

### Nested Parameters

Handle complex nested structures:

```ruby
class CreateOrder
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    Order.create!(
      user: user,
      items: order_items,
      shipping_address: shipping_address,
      billing_address: billing_address
    )
  end

  private

  def initialize(params = {})
    @user = params[:user]
    @items_params = params[:items] || []
    @shipping_address_params = params[:shipping_address] || {}
    @billing_address_params = params[:billing_address] || {}
  end

  attr_reader :user

  def order_items
    @items_params.map do |item_params|
      OrderItem.new(
        product_id: item_params[:product_id],
        quantity: item_params[:quantity],
        price: item_params[:price]
      )
    end
  end

  def shipping_address
    Address.new(@shipping_address_params)
  end

  def billing_address
    Address.new(@billing_address_params)
  end
end

# Usage
SimpleCommandDispatcher.call(
  command: :create_order,
  request_params: {
    user: current_user,
    items: [
      { product_id: 1, quantity: 2, price: 10.00 },
      { product_id: 3, quantity: 1, price: 25.00 }
    ],
    shipping_address: {
      street: '123 Main St',
      city: 'Springfield',
      state: 'IL',
      zip: '62701'
    },
    billing_address: {
      street: '456 Oak Ave',
      city: 'Springfield',
      state: 'IL',
      zip: '62702'
    }
  }
)
```

### Dependency Injection

Inject dependencies through parameters:

```ruby
class SendEmail
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    mailer.send_email(to: recipient, subject: subject, body: body).deliver_now
  end

  private

  def initialize(params = {}, mailer: ActionMailer::Base)
    @recipient = params[:recipient]
    @subject = params[:subject]
    @body = params[:body]
    @mailer = mailer
  end

  attr_reader :recipient, :subject, :body, :mailer
end

# Usage in production
SendEmail.call(recipient: 'user@example.com', subject: 'Hello', body: 'Test')

# Usage in tests with mock mailer
SendEmail.call(
  { recipient: 'user@example.com', subject: 'Hello', body: 'Test' },
  mailer: MockMailer
)
```

## Parameter Validation

### Basic Validation

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_params
    return nil if errors.any?

    User.create!(email: email, password: password)
  end

  private

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
  end

  attr_reader :email, :password

  def validate_params
    errors.add(:email, 'is required') if email.blank?
    errors.add(:password, 'is required') if password.blank?
    errors.add(:password, 'is too short') if password.present? && password.length < 8
  end
end
```

### Type Checking

```ruby
class CalculateTotal
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_types
    return nil if errors.any?

    items.sum { |item| item[:price] * item[:quantity] }
  end

  private

  def initialize(params = {})
    @items = params[:items]
  end

  attr_reader :items

  def validate_types
    unless items.is_a?(Array)
      errors.add(:items, 'must be an array')
      return
    end

    items.each_with_index do |item, index|
      errors.add(:items, "item #{index} must be a hash") unless item.is_a?(Hash)
      errors.add(:items, "item #{index} must have :price") unless item.key?(:price)
      errors.add(:items, "item #{index} must have :quantity") unless item.key?(:quantity)
    end
  end
end
```

### Sanitization

```ruby
class SearchProducts
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    Product.where("name ILIKE ?", sanitized_query)
           .limit(sanitized_limit)
  end

  private

  def initialize(params = {})
    @query = params[:query]
    @limit = params[:limit]
  end

  def sanitized_query
    "%#{@query.to_s.strip}%"
  end

  def sanitized_limit
    limit_int = @limit.to_i
    limit_int.between?(1, 100) ? limit_int : 10
  end
end
```

## Testing Parameter Handling

```ruby
RSpec.describe CreateUser do
  describe 'parameter handling' do
    context 'with hash parameters' do
      it 'accepts hash params' do
        command = described_class.call(email: 'test@example.com', password: 'secret')
        expect(command.success?).to be true
      end
    end

    context 'with nil parameters' do
      it 'handles nil gracefully' do
        command = described_class.call
        expect(command.failure?).to be true
        expect(command.errors).not_to be_empty
      end
    end

    context 'with missing required parameters' do
      it 'validates required params' do
        command = described_class.call(email: 'test@example.com')
        expect(command.failure?).to be true
        expect(command.errors[:password]).to include('is required')
      end
    end

    context 'with extra parameters' do
      it 'ignores extra params' do
        command = described_class.call(
          email: 'test@example.com',
          password: 'secret',
          extra_field: 'ignored'
        )
        expect(command.success?).to be true
      end
    end
  end
end
```

## Best Practices

1. **Use Hash Parameters** for most commands (matches Rails params)
2. **Validate All Inputs** before processing
3. **Provide Defaults** for optional parameters
4. **Use Strong Parameters** in controllers for security
5. **Document Required Parameters** in comments or specs
6. **Handle nil Gracefully** with presence checks
7. **Sanitize User Input** to prevent injection attacks
8. **Use Type Checking** for complex parameters

## Summary

SCD's parameter handling is:
- **Automatic** - Detects initializer signature
- **Flexible** - Supports Hash, Array, single values, nil
- **Rails-Friendly** - Works seamlessly with Rails params
- **Type-Agnostic** - You control what types you accept

## Next Steps

- [Learn about error handling](Error-Handling.md)
- [Explore validation patterns](Creating-Commands.md)
- [See real-world examples](Examples-Authentication.md)

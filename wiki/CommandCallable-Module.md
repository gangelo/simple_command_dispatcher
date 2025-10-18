# CommandCallable Module

The `CommandCallable` module is the magic behind SCD's command standardization.

## What is CommandCallable?

One line of code that gives your commands superpowers:

```ruby
prepend SimpleCommandDispatcher::Commands::CommandCallable
```

## What You Get (Automatically!)

Without `CommandCallable`, you'd need to manually implement:
- ❌ A `.call` class method
- ❌ Success/failure tracking
- ❌ Error collection and management
- ❌ Result storage

With `CommandCallable`:
- ✅ All of the above, automatically
- ✅ Zero boilerplate
- ✅ Just focus on your business logic

## How It Works

When you prepend `CommandCallable`, it adds methods to your class **before** your own methods:

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Hello, World!"
  end
end
```

Now `MyCommand` has:
- A `.call` class method (from CommandCallable)
- Your `#call` instance method (your code)
- `success?`, `failure?`, `errors`, `result` (from CommandCallable)

It just works!

## What CommandCallable Adds

### 1. Class Method: `.call`

Automatically creates a class method that:
1. Instantiates your command class
2. Calls the instance `call` method
3. Tracks execution state
4. Returns the command instance

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Result value"
  end

  private

  def initialize(params = {})
    @params = params
  end
end

# The .call class method is automatically available
command = MyCommand.call(foo: 'bar')
```

### 2. Instance Variable: `@result`

Stores the return value from your `call` method:

```ruby
class GetUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.find_by(id: user_id)
  end

  private

  def initialize(params = {})
    @user_id = params[:user_id]
  end

  attr_reader :user_id
end

command = GetUser.call(user_id: 123)
command.result  # => #<User id: 123, ...>
```

### 3. Instance Variable: `@called`

Tracks whether the command has been executed:

```ruby
command = MyCommand.new  # Direct instantiation (not recommended)
command.instance_variable_get(:@called)  # => nil

command.call
command.instance_variable_get(:@called)  # => true
```

This ensures `success?` and `failure?` only work after execution.

### 4. Method: `errors`

Returns an error collection object:

```ruby
class ValidateEmail
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    errors.add(:email, 'is required') if email.blank?
    errors.add(:email, 'is invalid') unless email.match?(/\A[^@]+@[^@]+\z/)

    return nil if errors.any?

    "Valid!"
  end

  private

  def initialize(params = {})
    @email = params[:email]
  end

  attr_reader :email
end

command = ValidateEmail.call(email: '')
command.errors[:email]  # => ['is required', 'is invalid']
```

### 5. Method: `success?`

Returns `true` if the command was called and has no errors:

```ruby
command = MyCommand.call
command.success?  # => true if errors.empty?
```

**Important:** Returns `false` if the command hasn't been called yet.

### 6. Method: `failure?`

Returns `true` if the command was called and has errors:

```ruby
command = MyCommand.call
command.failure?  # => true if errors.any?
```

## The Errors Object

The `errors` object is an instance of `SimpleCommandDispatcher::Commands::Errors`, which inherits from `Hash`.

### Adding Errors

```ruby
# Add a single error
errors.add(:field_name, 'error message')

# Add multiple errors to the same field
errors.add(:email, 'is required')
errors.add(:email, 'is invalid')

# Add a general error (not tied to a field)
errors.add(:base, 'Something went wrong')
```

### Preventing Duplicate Errors

The `add` method automatically prevents duplicate messages for the same field:

```ruby
errors.add(:email, 'is required')
errors.add(:email, 'is required')  # Ignored - duplicate

errors[:email]  # => ['is required']  (only one entry)
```

### Adding Multiple Errors from a Hash

```ruby
errors.add_multiple_errors({
  email: ['is required', 'is invalid'],
  password: ['is too short']
})
```

This is useful when composing commands:

```ruby
class CompositeCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    other_command = OtherCommand.call
    if other_command.failure?
      errors.add_multiple_errors(other_command.errors)
      return nil
    end

    # Continue processing
  end
end
```

### Accessing Errors

```ruby
# Get errors for a specific field
command.errors[:email]  # => ['is required', 'is invalid']

# Check if any errors exist
command.errors.any?  # => true/false
command.errors.empty?  # => true/false

# Get all errors as a hash
command.errors.to_h  # => { email: ['is required'], password: ['is too short'] }
```

### Getting Formatted Error Messages

```ruby
command.errors.full_messages
# => ['Email is required', 'Email is invalid', 'Password is too short']

# For :base errors, only the message is returned (no field name prefix)
errors.add(:base, 'Operation failed')
command.errors.full_messages  # => ['Operation failed']
```

## Return Value: Command Instance vs Result

**Critical Concept:** `CommandCallable`'s `.call` method returns the **command instance**, not the raw result.

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "This is the result"
  end
end

command = MyCommand.call

# command is the MyCommand instance
command.class  # => MyCommand

# Access the actual result via .result
command.result  # => "This is the result"

# Access success/failure
command.success?  # => true

# Access errors
command.errors  # => {}
```

### Why This Design?

This design allows you to check success/failure and access errors on the same object:

```ruby
command = AuthenticateUser.call(email: 'user@example.com', password: 'wrong')

if command.success?
  # Access the result
  user = command.result
  render json: { user: user }
else
  # Access the errors
  render json: { errors: command.errors }, status: :unauthorized
end
```

## Common Patterns

### Pattern 1: Early Return on Validation Failure

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_user_data
    return nil if errors.any?

    User.create!(email: email, password: password)
  end

  private

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
  end

  attr_reader :email, :password

  def validate_user_data
    errors.add(:email, 'is required') if email.blank?
    errors.add(:password, 'is required') if password.blank?
  end
end
```

### Pattern 2: Multiple Validation Steps

```ruby
class ProcessOrder
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_inventory
    return nil if errors.any?

    validate_payment
    return nil if errors.any?

    validate_shipping
    return nil if errors.any?

    create_order
  end

  private

  def validate_inventory
    errors.add(:product, 'is out of stock') unless product.in_stock?
  end

  def validate_payment
    errors.add(:payment, 'card declined') unless payment_valid?
  end

  def validate_shipping
    errors.add(:address, 'cannot ship to location') unless can_ship_to?(address)
  end

  def create_order
    Order.create!(product: product, user: user, address: address)
  end
end
```

### Pattern 3: Exception Handling with Errors

```ruby
class ChargeCard
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_charge_data
    return nil if errors.any?

    charge_card
  rescue Stripe::CardError => e
    errors.add(:card, e.message)
    nil
  rescue Stripe::InvalidRequestError => e
    errors.add(:base, "Invalid request: #{e.message}")
    nil
  rescue StandardError => e
    errors.add(:base, "Unexpected error: #{e.message}")
    nil
  end

  private

  def validate_charge_data
    errors.add(:amount, 'must be positive') if amount <= 0
    errors.add(:card_token, 'is required') if card_token.blank?
  end

  def charge_card
    Stripe::Charge.create(
      amount: amount,
      currency: 'usd',
      source: card_token
    )
  end
end
```

### Pattern 4: Composing Commands

```ruby
class RegisterUserWorkflow
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    user = create_user
    return nil if errors.any?

    send_welcome_email(user)
    setup_default_settings(user)

    user
  end

  private

  def create_user
    command = CreateUser.call(email: email, password: password)

    if command.failure?
      errors.add_multiple_errors(command.errors)
      return nil
    end

    command.result
  end

  def send_welcome_email(user)
    command = SendWelcomeEmail.call(user: user)
    errors.add(:email, 'could not be sent') if command.failure?
  end

  def setup_default_settings(user)
    command = CreateDefaultSettings.call(user: user)
    errors.add(:settings, 'could not be created') if command.failure?
  end
end
```

## Testing with CommandCallable

Commands using `CommandCallable` are easy to test:

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
        expect(command.result).to eq('expected value')
      end

      it 'has no errors' do
        expect(command.errors).to be_empty
      end
    end

    context 'with invalid params' do
      let(:params) { { email: '' } }

      it 'fails' do
        expect(command.failure?).to be true
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'includes error messages' do
        expect(command.errors[:email]).to include('is required')
      end

      it 'includes formatted error messages' do
        expect(command.errors.full_messages).to include('Email is required')
      end
    end
  end
end
```

## Commands Without CommandCallable

You can create commands without `CommandCallable`, but you'll need to implement the interface yourself:

```ruby
class CustomCommand
  # No CommandCallable

  # Must implement a .call class method
  def self.call(*args)
    new(*args).call
  end

  def initialize(params = {})
    @params = params
  end

  def call
    # Your logic
    # Return whatever you want
    "Custom result"
  end
end
```

This gives you complete control but loses the standardized interface.

## Advanced: Accessing the Command Instance

Sometimes you need to access the command instance directly:

```ruby
class ComplexCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  attr_reader :intermediate_value

  def call
    @intermediate_value = calculate_intermediate
    final_result
  end

  private

  def calculate_intermediate
    # Complex calculation
    42
  end

  def final_result
    intermediate_value * 2
  end
end

command = ComplexCommand.call
command.result  # => 84
command.intermediate_value  # => 42 (accessible because of attr_reader)
```

This is useful for debugging or when you need to access intermediate state.

## Summary

`CommandCallable` provides:

1. **Automatic `.call` class method** - No boilerplate needed
2. **Result tracking** - Access via `command.result`
3. **Success/failure methods** - `command.success?` and `command.failure?`
4. **Error collection** - Built-in `errors` object with helpful methods
5. **Standardized interface** - All commands work the same way

**Best Practices:**
- Always prepend `CommandCallable` for consistency
- Make `initialize` private to enforce proper usage
- Return `nil` when validation fails
- Use `errors.add` for all validation errors
- Test both success and failure cases

## Next Steps

- [Learn about parameter handling](Parameter-Handling.md)
- [Explore error handling patterns](Error-Handling.md)
- [See real-world examples](Examples-Authentication.md)

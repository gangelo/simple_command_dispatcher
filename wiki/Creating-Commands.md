# Creating Commands

Learn how to create command classes that work seamlessly with simple_command_dispatcher.

## Basic Command Structure

Every command needs just two things:

1. **Prepend `CommandCallable`** - Gives you the `.call` class method and success tracking
2. **Define `call` method** - Your business logic goes here

## The Minimal Command

The simplest command possible:

```ruby
class HelloWorld
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    "Hello, World!"
  end
end
```

That's it! Use it like this:

```ruby
command = HelloWorld.call
command.result    # => "Hello, World!"
command.success?  # => true
command.errors    # => {} (empty)
```

Three lines of code, fully functional command!

## Commands with Parameters

Most commands need to accept parameters:

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

Usage:

```ruby
command = GreetUser.call(name: 'Alice')
command.result  # => "Hello, Alice!"
```

## Best Practice: Make `initialize` Private

**Always make `initialize` private.** This forces everyone to use `.call`:

```ruby
class MyCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Your logic
  end

  private  # Everything below is private

  def initialize(params = {})
    @params = params
  end
end
```

**Why?** Because now this won't work:

```ruby
MyCommand.new(params)  # ❌ Error: private method `new' called
```

But this will:

```ruby
MyCommand.call(params)  # ✅ Correct way
```

This ensures success/failure tracking always works!

## Commands with Validation

Add validation to ensure data integrity:

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_user_data
    return nil if errors.any?

    create_user
  end

  private

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
    @name = params[:name]
  end

  attr_reader :email, :password, :name

  def validate_user_data
    errors.add(:email, 'is required') if email.blank?
    errors.add(:email, 'is invalid') unless email.match?(/\A[^@]+@[^@]+\z/)
    errors.add(:password, 'is required') if password.blank?
    errors.add(:password, 'is too short') if password.present? && password.length < 8
    errors.add(:name, 'is required') if name.blank?
  end

  def create_user
    User.create!(
      email: email,
      password: password,
      name: name
    )
  end
end
```

Usage:

```ruby
# Valid data
command = CreateUser.call(
  email: 'alice@example.com',
  password: 'secure123',
  name: 'Alice'
)
command.success?  # => true
command.result    # => #<User id: 1, email: "alice@example.com", ...>

# Invalid data
command = CreateUser.call(email: '', password: '123')
command.failure?  # => true
command.errors.full_messages
# => ['Email is required', 'Email is invalid', 'Password is too short', 'Name is required']
```

## Commands with Error Handling

Handle exceptions gracefully:

```ruby
class ProcessPayment
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_payment_data
    return nil if errors.any?

    charge_card
  rescue Stripe::CardError => e
    errors.add(:card, e.message)
    nil
  rescue StandardError => e
    errors.add(:base, "Payment processing failed: #{e.message}")
    nil
  end

  private

  def initialize(params = {})
    @amount = params[:amount]
    @card_token = params[:card_token]
  end

  attr_reader :amount, :card_token

  def validate_payment_data
    errors.add(:amount, 'must be positive') if amount.to_i <= 0
    errors.add(:card_token, 'is required') if card_token.blank?
  end

  def charge_card
    Stripe::Charge.create(
      amount: (amount.to_f * 100).to_i,  # Convert to cents
      currency: 'usd',
      source: card_token
    )
  end
end
```

## Namespaced Commands

Organize commands into modules to match your application structure:

```ruby
# app/commands/api/v1/users/create.rb
module Api
  module V1
    module Users
      class Create
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def call
          validate_user_data
          return nil if errors.any?

          create_user
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

        def create_user
          User.create!(email: email, password: password)
        end
      end
    end
  end
end
```

Usage:

```ruby
# Direct call
command = Api::V1::Users::Create.call(email: 'alice@example.com', password: 'secret')

# Through dispatcher
command = SimpleCommandDispatcher.call(
  command: :create,
  command_namespace: 'api/v1/users',
  request_params: { email: 'alice@example.com', password: 'secret' }
)

# Or using full path
command = SimpleCommandDispatcher.call(
  command: '/api/v1/users/create',
  request_params: { email: 'alice@example.com', password: 'secret' }
)
```

## Commands that Return Different Types

Commands can return any type of value:

### Returning a Boolean

```ruby
class IsUserAdmin
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    user = User.find_by(id: user_id)
    user&.admin? || false
  end

  private

  def initialize(params = {})
    @user_id = params[:user_id]
  end

  attr_reader :user_id
end
```

### Returning an ActiveRecord Collection

```ruby
class SearchUsers
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    User.where("name ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%")
        .limit(limit)
  end

  private

  def initialize(params = {})
    @query = params[:query] || ''
    @limit = params[:limit] || 10
  end

  attr_reader :query, :limit
end
```

### Returning a Hash

```ruby
class GetUserStats
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    {
      total_users: User.count,
      active_users: User.where(active: true).count,
      admin_users: User.where(admin: true).count,
      created_today: User.where('created_at >= ?', Date.today).count
    }
  end
end
```

### Returning nil

```ruby
class DeactivateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    user = User.find_by(id: user_id)
    return nil unless user

    user.update(active: false)
    nil  # Explicit nil return for void operations
  end

  private

  def initialize(params = {})
    @user_id = params[:user_id]
  end

  attr_reader :user_id
end
```

## Commands with Dependencies

Inject dependencies through the initializer:

```ruby
class SendWelcomeEmail
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_inputs
    return nil if errors.any?

    mailer.welcome_email(user).deliver_now
    true
  end

  private

  def initialize(params = {}, mailer: UserMailer)
    @user = params[:user]
    @mailer = mailer
  end

  attr_reader :user, :mailer

  def validate_inputs
    errors.add(:user, 'is required') if user.nil?
    errors.add(:user, 'must have an email') if user && !user.email.present?
  end
end
```

Usage:

```ruby
# With default mailer
command = SendWelcomeEmail.call(user: user)

# With custom mailer (useful for testing)
command = SendWelcomeEmail.call(
  { user: user },
  mailer: MockMailer
)
```

## Commands that Call Other Commands

Commands can compose other commands:

```ruby
class RegisterUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Step 1: Create the user
    create_command = CreateUser.call(email: email, password: password, name: name)
    if create_command.failure?
      errors.add_multiple_errors(create_command.errors)
      return nil
    end

    user = create_command.result

    # Step 2: Send welcome email
    email_command = SendWelcomeEmail.call(user: user)
    if email_command.failure?
      errors.add(:email, 'could not be sent')
      # Note: User was already created, might need cleanup
    end

    user
  end

  private

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
    @name = params[:name]
  end

  attr_reader :email, :password, :name
end
```

## Commands with Complex Business Logic

Break complex logic into private methods:

```ruby
class CalculateShippingCost
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_inputs
    return nil if errors.any?

    base_cost + weight_cost + distance_cost + speed_premium - discounts
  end

  private

  def initialize(params = {})
    @weight = params[:weight]
    @distance = params[:distance]
    @shipping_speed = params[:shipping_speed] || 'standard'
    @user = params[:user]
  end

  attr_reader :weight, :distance, :shipping_speed, :user

  def validate_inputs
    errors.add(:weight, 'must be positive') if weight.to_f <= 0
    errors.add(:distance, 'must be positive') if distance.to_f <= 0
  end

  def base_cost
    5.00
  end

  def weight_cost
    weight.to_f * 0.50
  end

  def distance_cost
    distance.to_f * 0.10
  end

  def speed_premium
    case shipping_speed
    when 'express' then 15.00
    when 'overnight' then 30.00
    else 0.00
    end
  end

  def discounts
    return 0.00 unless user

    user.premium? ? 5.00 : 0.00
  end
end
```

## Testing Commands

Commands are easy to test in isolation:

```ruby
# spec/commands/create_user_spec.rb
RSpec.describe CreateUser do
  describe '#call' do
    context 'with valid params' do
      let(:params) do
        {
          email: 'alice@example.com',
          password: 'secure123',
          name: 'Alice'
        }
      end

      it 'creates a user' do
        expect { described_class.call(params) }.to change(User, :count).by(1)
      end

      it 'returns success' do
        command = described_class.call(params)
        expect(command.success?).to be true
      end

      it 'returns the created user' do
        command = described_class.call(params)
        expect(command.result).to be_a(User)
        expect(command.result.email).to eq('alice@example.com')
      end
    end

    context 'with invalid params' do
      let(:params) { { email: '', password: '123' } }

      it 'does not create a user' do
        expect { described_class.call(params) }.not_to change(User, :count)
      end

      it 'returns failure' do
        command = described_class.call(params)
        expect(command.failure?).to be true
      end

      it 'includes validation errors' do
        command = described_class.call(params)
        expect(command.errors[:email]).to include('is required')
        expect(command.errors[:password]).to include('is too short')
      end
    end
  end
end
```

## Command Patterns to Avoid

### Don't Mix Concerns

```ruby
# BAD: Command that does too many things
class UserRegistration
  def call
    create_user
    send_email
    create_audit_log
    charge_credit_card
    setup_stripe_subscription
    create_default_settings
  end
end

# GOOD: Separate commands for separate concerns
class CreateUser
  # Just create the user
end

class SendWelcomeEmail
  # Just send email
end

class SetupSubscription
  # Just handle subscription
end
```

### Don't Use Instance Variables for Everything

```ruby
# BAD: Too many instance variables
def call
  @user = find_user
  @account = create_account
  @subscription = create_subscription
  @payment = process_payment
end

# GOOD: Use local variables and only store what's needed
def call
  user = find_user
  account = create_account(user)
  subscription = create_subscription(account)
  process_payment(subscription)
end
```

### Don't Skip Validation

```ruby
# BAD: Assuming data is valid
def call
  User.create!(email: email, password: password)
end

# GOOD: Always validate
def call
  validate_user_data
  return nil if errors.any?

  User.create!(email: email, password: password)
end
```

## Summary

When creating commands:

- Always prepend `CommandCallable` for standardization
- Make `initialize` private to enforce proper usage
- Add validation before processing
- Handle exceptions gracefully
- Return meaningful values
- Use namespaces for organization
- Keep commands focused on a single responsibility
- Write tests for your commands

## Next Steps

- [Learn about the CommandCallable module in depth](CommandCallable-Module.md)
- [Master parameter handling](Parameter-Handling.md)
- [Explore real-world examples](Examples-Authentication.md)

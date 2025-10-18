# Error Handling

Master validation and error handling in your commands.

## Overview

With `CommandCallable`, you get an `errors` object automatically. It's just a Hash with superpowers.

## The Errors Object

Every command has it built-in:

### Adding Errors

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Add errors to specific fields
    errors.add(:email, 'is required') if email.blank?
    errors.add(:email, 'is invalid') unless valid_email?

    # Stop if there are errors
    return nil if errors.any?

    User.create!(email: email, password: password)
  end
end
```

### How Errors Are Stored

Simple! It's a Hash where keys are field names and values are arrays of messages:

```ruby
{
  email: ['is required', 'is invalid'],
  password: ['is too short']
}
```

No complex objects. Just a Hash!

## The Standard Pattern

This pattern is used in 90% of commands:

```ruby
class ProcessPayment
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Step 1: Validate
    validate_payment_data
    return nil if errors.any?

    # Step 2: Process (only if valid)
    charge_card
  end

  private

  def validate_payment_data
    errors.add(:amount, 'must be positive') if amount.to_f <= 0
    errors.add(:card_token, 'is required') if card_token.blank?
  end

  def charge_card
    Stripe::Charge.create(amount: amount, source: card_token)
  end
end
```

**The pattern:**
1. Validate and add errors
2. Return `nil` if any errors
3. Process only if validation passed

### Pattern 2: Multiple Validation Steps

Validate in stages for complex logic:

```ruby
class CreateOrder
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_user
    return nil if errors.any?

    validate_inventory
    return nil if errors.any?

    validate_shipping
    return nil if errors.any?

    create_order
  end

  private

  def validate_user
    errors.add(:user, 'must be authenticated') unless user
  end

  def validate_inventory
    items.each do |item|
      errors.add(:items, "#{item.name} is out of stock") unless item.in_stock?
    end
  end

  def validate_shipping
    errors.add(:address, 'cannot ship to location') unless can_ship?
  end
end
```

### Pattern 3: Exception Handling

Catch exceptions and convert them to errors:

```ruby
class ImportData
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_file
    return nil if errors.any?

    import_file
  rescue CSV::MalformedCSVError => e
    errors.add(:file, "is malformed: #{e.message}")
    nil
  rescue Encoding::InvalidByteSequenceError
    errors.add(:file, 'has invalid encoding')
    nil
  rescue StandardError => e
    errors.add(:base, "Import failed: #{e.message}")
    nil
  end
end
```

## Working with Errors

### Checking for Errors

```ruby
command = CreateUser.call(params)

# Check if any errors exist
command.errors.any?   # => true/false
command.errors.empty? # => true/false

# Count errors
command.errors.count # => 2

# Check specific field
command.errors[:email].present?  # => true/false
```

### Accessing Error Messages

```ruby
command = CreateUser.call(email: '', password: '123')

# Get errors for a specific field
command.errors[:email]
# => ['is required']

command.errors[:password]
# => ['is too short']

# Get all errors as a hash
command.errors.to_h
# => { email: ['is required'], password: ['is too short'] }

# Get formatted messages
command.errors.full_messages
# => ['Email is required', 'Password is too short']
```

### Iterating Over Errors

```ruby
command.errors.each do |field, messages|
  puts "#{field}: #{messages.join(', ')}"
end

# Output:
# email: is required
# password: is too short
```

## Advanced Error Patterns

### Adding Multiple Errors from Another Command

```ruby
class RegisterUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    # Call another command
    create_command = CreateUser.call(email: email, password: password)

    # If it failed, copy its errors
    if create_command.failure?
      errors.add_multiple_errors(create_command.errors)
      return nil
    end

    user = create_command.result

    # Continue processing...
    send_welcome_email(user)

    user
  end
end
```

### Conditional Error Messages

```ruby
class UpdateProfile
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_changes
    return nil if errors.any?

    user.update!(updated_params)
  end

  private

  def validate_changes
    if email_changed?
      validate_email
    end

    if password_changed?
      validate_password
    end

    if phone_changed?
      validate_phone
    end
  end

  def validate_email
    errors.add(:email, 'is invalid') unless email.match?(/\A[^@]+@[^@]+\z/)
    errors.add(:email, 'is already taken') if email_taken?
  end

  def validate_password
    errors.add(:password, 'is too short') if password.length < 8
    errors.add(:password, 'must contain a number') unless password.match?(/\d/)
  end

  def validate_phone
    errors.add(:phone, 'is invalid') unless phone.match?(/\A\d{10}\z/)
  end
end
```

### Custom Error Keys

Use `:base` for general errors not tied to a specific field:

```ruby
class ProcessTransaction
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    if insufficient_funds?
      errors.add(:base, 'Insufficient funds for this transaction')
      return nil
    end

    if account_locked?
      errors.add(:base, 'Account is temporarily locked')
      return nil
    end

    process_transaction
  end
end
```

The `:base` key is formatted without a field name prefix:

```ruby
errors.add(:base, 'Something went wrong')
errors.full_messages  # => ['Something went wrong']  (no "Base" prefix)
```

### Internationalization (i18n)

Use i18n for error messages:

```ruby
class CreateUser
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    validate_user_data
    return nil if errors.any?

    User.create!(email: email, password: password)
  end

  private

  def validate_user_data
    errors.add(:email, I18n.t('errors.email.required')) if email.blank?
    errors.add(:email, I18n.t('errors.email.invalid')) unless valid_email?
  end
end

# config/locales/en.yml
# en:
#   errors:
#     email:
#       required: "is required"
#       invalid: "is not a valid email address"
```

## Controller Error Handling

### Basic Controller Pattern

```ruby
class UsersController < ApplicationController
  def create
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: user_params
    )

    if command.success?
      render json: { user: command.result }, status: :created
    else
      render json: { errors: command.errors }, status: :unprocessable_entity
    end
  end
end
```

### Custom Error Responses

```ruby
class Api::V1::UsersController < ApplicationController
  def create
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: user_params
    )

    if command.success?
      render json: {
        data: UserSerializer.new(command.result).as_json
      }, status: :created
    else
      render json: {
        errors: format_errors(command.errors)
      }, status: :unprocessable_entity
    end
  end

  private

  def format_errors(errors)
    {
      message: 'Validation failed',
      details: errors.full_messages,
      fields: errors.to_h
    }
  end
end

# Response:
# {
#   "errors": {
#     "message": "Validation failed",
#     "details": ["Email is required", "Password is too short"],
#     "fields": {
#       "email": ["is required"],
#       "password": ["is too short"]
#     }
#   }
# }
```

### Handling Dispatcher Errors

Handle errors from the dispatcher itself:

```ruby
def create
  command = SimpleCommandDispatcher.call(
    command: request.path,
    request_params: user_params
  )

  handle_command_response(command)
rescue SimpleCommandDispatcher::Errors::InvalidClassConstantError => e
  render json: {
    error: 'Command not found',
    message: e.message
  }, status: :not_found
rescue SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError => e
  render json: {
    error: 'Invalid command configuration',
    message: e.message
  }, status: :internal_server_error
rescue StandardError => e
  Rails.logger.error("Unexpected error: #{e.message}")
  render json: {
    error: 'Internal server error'
  }, status: :internal_server_error
end
```

## Testing Error Handling

### RSpec Examples

```ruby
RSpec.describe CreateUser do
  describe 'error handling' do
    context 'with missing email' do
      it 'adds email error' do
        command = described_class.call(password: 'secret123')
        expect(command.errors[:email]).to include('is required')
      end

      it 'returns failure' do
        command = described_class.call(password: 'secret123')
        expect(command.failure?).to be true
      end

      it 'returns nil result' do
        command = described_class.call(password: 'secret123')
        expect(command.result).to be_nil
      end
    end

    context 'with invalid email' do
      it 'adds email validation error' do
        command = described_class.call(
          email: 'invalid',
          password: 'secret123'
        )
        expect(command.errors[:email]).to include('is invalid')
      end
    end

    context 'with multiple errors' do
      it 'accumulates all errors' do
        command = described_class.call(email: '', password: '123')
        expect(command.errors.count).to eq(3)
        expect(command.errors[:email]).to include('is required')
        expect(command.errors[:password]).to include('is too short')
      end
    end

    context 'with valid params' do
      it 'has no errors' do
        command = described_class.call(
          email: 'test@example.com',
          password: 'secure123'
        )
        expect(command.errors).to be_empty
      end
    end
  end
end
```

## Best Practices

1. **Validate Early** - Check inputs before processing
2. **Return nil on Errors** - Convention for failed commands
3. **Use Descriptive Messages** - Make errors helpful
4. **One Error Per Issue** - Don't duplicate error messages
5. **Handle Exceptions** - Convert exceptions to errors
6. **Use :base for General Errors** - For errors not tied to a field
7. **Test Error Cases** - Always test both success and failure paths
8. **Format Errors for APIs** - Provide structured error responses

## Common Patterns

### Pattern: Field-Specific Errors

```ruby
errors.add(:email, 'is required')
errors.add(:email, 'is invalid')
errors.add(:password, 'is too short')
```

### Pattern: General Errors

```ruby
errors.add(:base, 'Something went wrong')
errors.add(:base, 'Operation not permitted')
```

### Pattern: Nested Resource Errors

```ruby
errors.add('items[0].quantity', 'must be positive')
errors.add('shipping_address.zip', 'is invalid')
```

### Pattern: Error Accumulation

```ruby
def validate_all
  validate_user
  validate_payment  # Don't return early
  validate_shipping # Collect all errors
end
```

## Summary

Error handling in SCD:
- **Built-in Errors Object** - Automatic with CommandCallable
- **Field-Specific Errors** - Track which fields have issues
- **General Errors** - Use `:base` for non-field errors
- **Easy Checking** - `success?` and `failure?` methods
- **Formatted Messages** - `full_messages` for display
- **Testing Friendly** - Easy to test error conditions

## Next Steps

- [Learn about validation patterns](Creating-Commands.md)
- [See real-world examples](Examples-Authentication.md)
- [Master controller patterns](Dynamic-Dispatching.md)

# Authentication Example

Build a complete authentication system using SCD in under 10 minutes.

## What We're Building

A production-ready auth system with:
- ✅ User registration with validation
- ✅ Login/authentication
- ✅ Token-based sessions
- ✅ Proper error handling

**Best part:** It uses SCD's convention-over-configuration, so adding new auth features is trivial!

## File Structure

We'll create these files:

```
app/commands/api/v1/auth/
  ├── register_user.rb       # User signup
  ├── authenticate_user.rb   # Login
  └── validate_token.rb      # Check auth token

app/controllers/api/v1/
  ├── registrations_controller.rb
  └── sessions_controller.rb
```

**Notice:** Commands mirror the URL structure!

## Step 1: User Registration Command

```ruby
# app/commands/api/v1/auth/register_user.rb
module Api
  module V1
    module Auth
      class RegisterUser
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def call
          validate_user_data
          return nil if errors.any?

          check_existing_user
          return nil if errors.any?

          create_user
        end

        private

        def initialize(params = {})
          @email = params[:email]
          @password = params[:password]
          @password_confirmation = params[:password_confirmation]
          @name = params[:name]
        end

        attr_reader :email, :password, :password_confirmation, :name

        def validate_user_data
          errors.add(:email, 'is required') if email.blank?
          errors.add(:email, 'is invalid') unless valid_email?
          errors.add(:password, 'is required') if password.blank?
          errors.add(:password, 'is too short (minimum 8 characters)') if password.present? && password.length < 8
          errors.add(:password_confirmation, 'does not match password') if password != password_confirmation
          errors.add(:name, 'is required') if name.blank?
        end

        def valid_email?
          email.present? && email.match?(/\A[^@\s]+@[^@\s]+\z/)
        end

        def check_existing_user
          if User.exists?(email: email)
            errors.add(:email, 'is already taken')
          end
        end

        def create_user
          User.create!(
            email: email,
            password: password,
            password_digest: BCrypt::Password.create(password),
            name: name
          )
        end
      end
    end
  end
end
```

## Step 2: Authentication Command

```ruby
# app/commands/api/v1/auth/authenticate_user.rb
module Api
  module V1
    module Auth
      class AuthenticateUser
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def call
          validate_credentials
          return nil if errors.any?

          find_and_authenticate_user
        end

        private

        def initialize(params = {})
          @email = params[:email]
          @password = params[:password]
        end

        attr_reader :email, :password

        def validate_credentials
          errors.add(:email, 'is required') if email.blank?
          errors.add(:password, 'is required') if password.blank?
        end

        def find_and_authenticate_user
          user = User.find_by(email: email)

          unless user
            errors.add(:base, 'Invalid email or password')
            return nil
          end

          unless BCrypt::Password.new(user.password_digest) == password
            errors.add(:base, 'Invalid email or password')
            return nil
          end

          # Generate session token
          user.regenerate_auth_token
          user
        end
      end
    end
  end
end
```

## Step 3: Token Validation Command

```ruby
# app/commands/api/v1/auth/validate_token.rb
module Api
  module V1
    module Auth
      class ValidateToken
        prepend SimpleCommandDispatcher::Commands::CommandCallable

        def call
          validate_token_presence
          return nil if errors.any?

          find_user_by_token
        end

        private

        def initialize(params = {})
          @token = params[:token]
        end

        attr_reader :token

        def validate_token_presence
          errors.add(:token, 'is required') if token.blank?
        end

        def find_user_by_token
          user = User.find_by(auth_token: token)

          unless user
            errors.add(:token, 'is invalid')
            return nil
          end

          # Check token expiration
          if user.auth_token_expires_at && user.auth_token_expires_at < Time.current
            errors.add(:token, 'has expired')
            return nil
          end

          user
        end
      end
    end
  end
end
```

## Step 4: Registrations Controller

```ruby
# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < ApplicationController
      before_action :route_request

      def create
        # Action intentionally empty - routing handled by before_action
      end

      private

      def route_request
        command = SimpleCommandDispatcher.call(
          command: request.path,  # "/api/v1/auth/register_user"
          request_params: registration_params
        )

        if command.success?
          user = command.result
          render json: {
            user: {
              id: user.id,
              email: user.email,
              name: user.name
            },
            token: user.auth_token
          }, status: :created
        else
          render json: {
            errors: command.errors
          }, status: :unprocessable_entity
        end
      end

      def registration_params
        params.permit(:email, :password, :password_confirmation, :name)
      end
    end
  end
end
```

## Step 5: Sessions Controller

```ruby
# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
      before_action :route_request, only: [:create]

      def create
        # Action intentionally empty - routing handled by before_action
      end

      def destroy
        # Handle logout
        if current_user
          current_user.update(auth_token: nil, auth_token_expires_at: nil)
          render json: { message: 'Logged out successfully' }, status: :ok
        else
          render json: { error: 'Not authenticated' }, status: :unauthorized
        end
      end

      private

      def route_request
        command = SimpleCommandDispatcher.call(
          command: request.path,  # "/api/v1/auth/authenticate_user"
          request_params: session_params
        )

        if command.success?
          user = command.result
          render json: {
            user: {
              id: user.id,
              email: user.email,
              name: user.name
            },
            token: user.auth_token,
            expires_at: user.auth_token_expires_at
          }, status: :ok
        else
          render json: {
            errors: command.errors
          }, status: :unauthorized
        end
      end

      def session_params
        params.permit(:email, :password)
      end
    end
  end
end
```

## Step 6: Application Controller (Authentication Helper)

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user, except: [:create]

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last

    command = Api::V1::Auth::ValidateToken.call(token: token)

    if command.success?
      @current_user = command.result
    else
      render json: { errors: command.errors }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
```

## Step 7: User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_token :auth_token

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def regenerate_auth_token
    self.regenerate_auth_token
    self.auth_token_expires_at = 24.hours.from_now
    save!
  end
end
```

## Step 8: Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post 'register_user', to: 'registrations#create'
        post 'authenticate_user', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
      end
    end
  end
end
```

## Step 9: Migration

```ruby
# db/migrate/20240101000000_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :password_digest, null: false
      t.string :auth_token, index: { unique: true }
      t.datetime :auth_token_expires_at

      t.timestamps
    end
  end
end
```

## Usage Examples

### Register a New User

```bash
curl -X POST http://localhost:3000/api/v1/auth/register_user \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "secure123",
    "password_confirmation": "secure123",
    "name": "Alice Smith"
  }'

# Response:
{
  "user": {
    "id": 1,
    "email": "alice@example.com",
    "name": "Alice Smith"
  },
  "token": "abc123xyz789"
}
```

### Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/authenticate_user \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "secure123"
  }'

# Response:
{
  "user": {
    "id": 1,
    "email": "alice@example.com",
    "name": "Alice Smith"
  },
  "token": "abc123xyz789",
  "expires_at": "2024-01-02T12:00:00Z"
}
```

### Access Protected Resource

```bash
curl -X GET http://localhost:3000/api/v1/protected_resource \
  -H "Authorization: Bearer abc123xyz789"
```

### Logout

```bash
curl -X DELETE http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer abc123xyz789"

# Response:
{
  "message": "Logged out successfully"
}
```

## Testing

```ruby
# spec/commands/api/v1/auth/authenticate_user_spec.rb
RSpec.describe Api::V1::Auth::AuthenticateUser do
  describe '#call' do
    let!(:user) do
      User.create!(
        email: 'alice@example.com',
        password_digest: BCrypt::Password.create('secure123'),
        name: 'Alice'
      )
    end

    context 'with valid credentials' do
      let(:params) do
        {
          email: 'alice@example.com',
          password: 'secure123'
        }
      end

      it 'succeeds' do
        command = described_class.call(params)
        expect(command.success?).to be true
      end

      it 'returns the user' do
        command = described_class.call(params)
        expect(command.result).to eq(user)
      end

      it 'generates an auth token' do
        expect {
          described_class.call(params)
        }.to change { user.reload.auth_token }.from(nil)
      end
    end

    context 'with invalid email' do
      let(:params) do
        {
          email: 'wrong@example.com',
          password: 'secure123'
        }
      end

      it 'fails' do
        command = described_class.call(params)
        expect(command.failure?).to be true
      end

      it 'includes error message' do
        command = described_class.call(params)
        expect(command.errors[:base]).to include('Invalid email or password')
      end
    end

    context 'with invalid password' do
      let(:params) do
        {
          email: 'alice@example.com',
          password: 'wrong'
        }
      end

      it 'fails' do
        command = described_class.call(params)
        expect(command.failure?).to be true
      end
    end
  end
end
```

## Key Takeaways

1. **Convention Over Configuration**: Request paths automatically map to commands
   - `/api/v1/auth/register_user` → `Api::V1::Auth::RegisterUser`
   - `/api/v1/auth/authenticate_user` → `Api::V1::Auth::AuthenticateUser`

2. **Separation of Concerns**: Each command handles one responsibility
   - `RegisterUser` - User creation
   - `AuthenticateUser` - Login validation
   - `ValidateToken` - Token verification

3. **Consistent Error Handling**: All commands use the same error interface

4. **Testability**: Commands can be tested in isolation

5. **Reusability**: Commands can be called from anywhere (controllers, jobs, other commands)

## Next Steps

- [Payment Processing Example](Examples-Payment-Processing.md)
- [API Search Example](Examples-API-Search.md)
- [Error Handling Guide](Error-Handling.md)

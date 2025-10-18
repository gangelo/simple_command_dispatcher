# Dynamic Dispatching

Use SCD's convention-over-configuration to handle multiple actions with minimal code.

## The Power of Dynamic Dispatching

Instead of explicitly calling each command, let the request path determine which command runs.

### Before: Manual Routing

```ruby
class UsersController < ApplicationController
  def create
    CreateUser.call(params)
  end

  def update
    UpdateUser.call(params)
  end

  def delete
    DeleteUser.call(params)
  end

  def search
    SearchUsers.call(params)
  end

  def export
    ExportUsers.call(params)
  end
end
```

### After: Dynamic Dispatching

```ruby
class UsersController < ApplicationController
  before_action :dispatch

  def create; end
  def update; end
  def delete; end
  def search; end
  def export; end

  private

  def dispatch
    command = SimpleCommandDispatcher.call(
      command: request.path,
      request_params: params
    )

    if command.success?
      render json: { data: command.result }
    else
      render json: { errors: command.errors }, status: :unprocessable_entity
    end
  end
end
```

**One method handles all actions!** The path determines the command:
- `/api/v1/users/create` → `Api::V1::Users::Create.call(params)`
- `/api/v1/users/search` → `Api::V1::Users::Search.call(params)`

## Pattern 1: Single Action Controller

The simplest pattern—one controller action that routes all requests:

```ruby
# app/controllers/api/v1/mechs_controller.rb
module Api
  module V1
    class MechsController < ApplicationController
      before_action :route_request, except: [:index]

      def index
        render json: { mechs: Mech.all }
      end

      def search; end    # Empty - routing handled by before_action
      def create; end
      def update; end

      private

      def route_request
        command = SimpleCommandDispatcher.call(
          command: request.path,  # e.g., "/api/v1/mechs/search"
          request_params: params
        )

        if command.success?
          render json: { mechs: command.result }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

## Pattern 2: Nested Resource Routing

Handle complex nested routes dynamically:

```ruby
# Routes like: /api/v1/mechs/123/variants/456/update
module Api
  module V1
    class VariantsController < ApplicationController
      before_action :route_nested_request

      def update; end
      def destroy; end

      private

      def route_nested_request
        path_parts = request.path.split('/')
        action = path_parts.last
        resource_path = path_parts[0...-1]

        # Filter out numeric IDs to build namespace
        namespace_parts = resource_path.reject { |part| part.match?(/^\d+$/) }

        command = SimpleCommandDispatcher.call(
          command: action,
          command_namespace: namespace_parts,
          request_params: params.merge(extract_ids(path_parts))
        )

        handle_response(command)
      end

      def extract_ids(path_parts)
        {
          mech_id: path_parts[4],      # Position of mech ID
          variant_id: path_parts[6]     # Position of variant ID
        }
      end

      def handle_response(command)
        if command.success?
          render json: { data: command.result }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

## Pattern 3: Base API Controller

Create a reusable base controller for all API endpoints:

```ruby
# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    private

    def dispatch_command
      command = SimpleCommandDispatcher.call(
        command: request.path,
        request_params: command_params,
        options: dispatch_options
      )

      handle_command_response(command)
    end

    def command_params
      params.permit!.to_h
    end

    def dispatch_options
      { debug: Rails.env.development? }
    end

    def handle_command_response(command)
      if command.success?
        render_success(command.result)
      else
        render_failure(command.errors)
      end
    end

    def render_success(result)
      render json: { data: result }, status: :ok
    end

    def render_failure(errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end
end
```

Now all API controllers can inherit this:

```ruby
module Api
  module V1
    class UsersController < Api::BaseController
      before_action :dispatch_command

      def create; end
      def update; end
      def destroy; end
    end
  end
end
```

## Pattern 4: Action-Specific Responses

Customize responses based on the action:

```ruby
module Api
  module V1
    class UsersController < ApplicationController
      before_action :route_request

      def create; end
      def update; end
      def destroy; end

      private

      def route_request
        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: params
        )

        if command.success?
          render_success(command)
        else
          render json: { errors: command.errors }, status: error_status
        end
      end

      def render_success(command)
        case action_name
        when 'create'
          render json: { user: command.result }, status: :created
        when 'update'
          render json: { user: command.result }, status: :ok
        when 'destroy'
          head :no_content
        else
          render json: { data: command.result }, status: :ok
        end
      end

      def error_status
        case action_name
        when 'destroy'
          :not_found
        else
          :unprocessable_entity
        end
      end
    end
  end
end
```

## Pattern 5: Conditional Dispatching

Dispatch only specific actions:

```ruby
module Api
  module V1
    class MechsController < ApplicationController
      before_action :dispatch_if_applicable

      def index
        render json: { mechs: Mech.all }
      end

      def show
        render json: { mech: Mech.find(params[:id]) }
      end

      def search; end  # Dispatched
      def filter; end  # Dispatched
      def export; end  # Dispatched

      private

      DISPATCHED_ACTIONS = %w[search filter export].freeze

      def dispatch_if_applicable
        return unless DISPATCHED_ACTIONS.include?(action_name)

        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: params
        )

        if command.success?
          render json: { mechs: command.result }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

## Pattern 6: Multiple Namespaces

Handle different API versions with the same controller logic:

```ruby
# app/controllers/api/base_versioned_controller.rb
module Api
  class BaseVersionedController < ApplicationController
    private

    def dispatch_versioned_command
      # Automatically use the current namespace
      command = SimpleCommandDispatcher.call(
        command: request.path,  # Includes version in path
        request_params: params
      )

      handle_response(command)
    end
  end
end

# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < Api::BaseVersionedController
      before_action :dispatch_versioned_command

      def search; end
    end
  end
end

# app/controllers/api/v2/users_controller.rb
module Api
  module V2
    class UsersController < Api::BaseVersionedController
      before_action :dispatch_versioned_command

      def search; end
    end
  end
end
```

- `/api/v1/users/search` → `Api::V1::Users::Search.call`
- `/api/v2/users/search` → `Api::V2::Users::Search.call`

## Pattern 7: Fallback Commands

Provide default behavior for missing commands:

```ruby
module Api
  module V1
    class MechsController < ApplicationController
      before_action :route_request_with_fallback

      def search; end
      def filter; end

      private

      def route_request_with_fallback
        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: params
        )

        handle_response(command)
      rescue SimpleCommandDispatcher::Errors::InvalidClassConstantError
        # Command class doesn't exist, use fallback
        use_fallback_search
      end

      def use_fallback_search
        results = Mech.where("mech_name ILIKE ?", "%#{params[:query]}%")
        render json: { mechs: results }, status: :ok
      end

      def handle_response(command)
        if command.success?
          render json: { mechs: command.result }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

## Pattern 8: Command Result Transformations

Transform command results before rendering:

```ruby
module Api
  module V1
    class UsersController < ApplicationController
      before_action :route_and_transform

      def search; end
      def list; end

      private

      def route_and_transform
        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: params
        )

        if command.success?
          transformed = transform_result(command.result)
          render json: { data: transformed }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end

      def transform_result(result)
        case result
        when ActiveRecord::Relation
          result.map { |record| serialize_record(record) }
        when ActiveRecord::Base
          serialize_record(result)
        else
          result
        end
      end

      def serialize_record(record)
        record.as_json(only: [:id, :email, :name], methods: [:display_name])
      end
    end
  end
end
```

## Pattern 9: Debug Mode in Development

Enable debug logging automatically in development:

```ruby
module Api
  class BaseController < ApplicationController
    private

    def dispatch_command
      command = SimpleCommandDispatcher.call(
        command: request.path,
        request_params: params,
        options: { debug: debug_mode? }
      )

      handle_response(command)
    end

    def debug_mode?
      Rails.env.development? || params[:debug] == 'true'
    end
  end
end
```

## Pattern 10: Custom Error Handling

Customize error responses based on error types:

```ruby
module Api
  module V1
    class MechsController < ApplicationController
      before_action :route_with_error_handling

      def search; end

      private

      def route_with_error_handling
        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: params
        )

        handle_response(command)
      rescue SimpleCommandDispatcher::Errors::InvalidClassConstantError => e
        render json: {
          error: 'Command not found',
          message: e.message
        }, status: :not_implemented
      rescue SimpleCommandDispatcher::Errors::RequiredClassMethodMissingError => e
        render json: {
          error: 'Invalid command',
          message: e.message
        }, status: :internal_server_error
      rescue StandardError => e
        Rails.logger.error("Command execution failed: #{e.message}")
        render json: {
          error: 'Internal server error'
        }, status: :internal_server_error
      end

      def handle_response(command)
        if command.success?
          render json: { mechs: command.result }, status: :ok
        else
          render json: { errors: command.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

## Real-World Example: Complete API Controller

```ruby
module Api
  module V1
    class MechsController < ApplicationController
      before_action :authenticate_user!
      before_action :route_request, except: [:index, :show]

      # Standard RESTful actions
      def index
        render json: { mechs: Mech.all }
      end

      def show
        render json: { mech: Mech.find(params[:id]) }
      end

      # Dynamically dispatched actions
      def search; end
      def filter_by_tonnage; end
      def filter_by_year; end
      def export_csv; end

      private

      def route_request
        command = SimpleCommandDispatcher.call(
          command: request.path,
          request_params: mech_params,
          options: { debug: Rails.env.development? }
        )

        if command.success?
          render_success(command.result)
        else
          render_failure(command.errors)
        end
      rescue SimpleCommandDispatcher::Errors::InvalidClassConstantError
        render json: { error: 'Action not supported' }, status: :not_implemented
      end

      def render_success(result)
        case action_name
        when 'export_csv'
          send_data result, filename: 'mechs.csv', type: 'text/csv'
        else
          render json: { mechs: result }, status: :ok
        end
      end

      def render_failure(errors)
        render json: { errors: errors }, status: :unprocessable_entity
      end

      def mech_params
        params.permit(:query, :tonnage, :year, :variant, :cost, :format)
      end
    end
  end
end
```

## Testing Dynamic Dispatching

```ruby
RSpec.describe Api::V1::MechsController, type: :controller do
  describe 'GET #search' do
    it 'dispatches to the correct command' do
      expect(SimpleCommandDispatcher).to receive(:call).with(
        command: '/api/v1/mechs/search',
        request_params: hash_including('query' => 'Atlas')
      ).and_call_original

      get :search, params: { query: 'Atlas' }
    end

    it 'returns successful results' do
      create(:mech, mech_name: 'Atlas')

      get :search, params: { query: 'Atlas' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['mechs']).not_to be_empty
    end
  end
end
```

## Summary

Dynamic dispatching patterns offer:

1. **Less Boilerplate** - No explicit command instantiation in actions
2. **Consistency** - Same routing pattern across all endpoints
3. **Flexibility** - Easy to add new actions without controller changes
4. **Versioning** - Handle multiple API versions elegantly
5. **Testability** - Commands remain independently testable

**Best Practices:**
- Use `before_action` for common dispatching logic
- Create base controllers for shared behavior
- Handle errors appropriately
- Enable debug mode in development
- Document which actions use dynamic dispatching

## Next Steps

- [Versioning API Commands](Versioning-API-Commands.md)
- [Error Handling](Error-Handling.md)
- [Real-World Examples](Examples-API-Search.md)

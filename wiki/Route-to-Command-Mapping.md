# Route-to-Command Mapping

Deep dive into how simple_command_dispatcher automatically transforms request paths into Ruby class constants.

## The Transformation Process

Understanding how routes become commands is key to mastering SCD.

### Step-by-Step Example

```ruby
# Input
"/api/v1/users/authenticate_user"

# Step 1: Normalize separators
"api/v1/users/authenticate_user"

# Step 2: Split into segments
["api", "v1", "users", "authenticate_user"]

# Step 3: Camelize each segment
["Api", "V1", "Users", "AuthenticateUser"]

# Step 4: Join with ::
"Api::V1::Users::AuthenticateUser"

# Step 5: Constantize
Api::V1::Users::AuthenticateUser  # The actual class constant
```

## Supported Input Formats

SCD accepts routes in many formats:

### Slash Separators (Most Common)

```ruby
# Forward slashes (standard URL paths)
SimpleCommandDispatcher.call(command: '/api/v1/users/create')
# => Api::V1::Users::Create

# Without leading slash
SimpleCommandDispatcher.call(command: 'api/v1/users/create')
# => Api::V1::Users::Create
```

### Double Colon Separators

```ruby
# Ruby module syntax
SimpleCommandDispatcher.call(command: 'Api::V1::Users::Create')
# => Api::V1::Users::Create

# Mixed case
SimpleCommandDispatcher.call(command: 'api::v1::Users::create')
# => Api::V1::Users::Create
```

### Hyphen Separators

```ruby
# Kebab-case (common in URLs)
SimpleCommandDispatcher.call(command: 'create-user')
# => CreateUser

# With namespaces
SimpleCommandDispatcher.call(
  command: 'create-user',
  command_namespace: 'api-v1-users'
)
# => Api::V1::Users::CreateUser
```

### Dot Separators

```ruby
# Dot notation
SimpleCommandDispatcher.call(command: 'api.v1.users.create')
# => Api::V1::Users::Create
```

### Mixed Separators

```ruby
# All of these produce the same result
SimpleCommandDispatcher.call(command: 'api/v1.users::create-user')
SimpleCommandDispatcher.call(command: 'api::v1/users.create_user')
SimpleCommandDispatcher.call(command: 'api.v1::users/create_user')

# All become: Api::V1::Users::CreateUser
```

### Array Format

```ruby
# Array of segments
SimpleCommandDispatcher.call(
  command: [:create, :user],
  command_namespace: [:api, :v1, :users]
)
# => Api::V1::Users::CreateUser
```

## Camelization Rules

SCD uses Rails' proven `camelize` method with some enhancements:

### Underscores Become CamelCase

```ruby
'authenticate_user' → 'AuthenticateUser'
'create_user_session' → 'CreateUserSession'
'fetch_mech_data' → 'FetchMechData'
```

### Numbers Are Preserved

```ruby
'v1' → 'V1'
'v2' → 'V2'
'api_v1_beta2' → 'ApiV1Beta2'
```

### Acronyms Are Capitalized

```ruby
'api' → 'Api'
'json' → 'Json'
'xml' → 'Xml'
'http_client' → 'HttpClient'
```

### Case Sensitivity

```ruby
# Input case doesn't matter for standard words
'API' → 'Api'
'api' → 'Api'
'Api' → 'Api'

# But affects the output
'createUser' → 'CreateUser'  # Already camelCase
'create_user' → 'CreateUser'  # Snake case
```

## Unicode Support

SCD handles Unicode characters properly:

### Whitespace Removal

All Unicode whitespace is removed:

```ruby
'api :: v1 :: users' → 'Api::V1::Users'
'create  user' → 'CreateUser'  # Multiple spaces
'api\u00A0v1' → 'ApiV1'  # Non-breaking space (U+00A0)
```

### Unicode Characters in Names

```ruby
# Unicode characters are preserved
'café_command' → 'CaféCommand'
'naïve_search' → 'NaïveSearch'
```

## Namespace Handling

Namespaces can be specified separately or included in the command:

### Separate Namespace

```ruby
SimpleCommandDispatcher.call(
  command: :create,
  command_namespace: 'api/v1/users'
)
# => Api::V1::Users::Create
```

### Namespace in Command

```ruby
SimpleCommandDispatcher.call(
  command: 'api/v1/users/create'
  # No namespace needed
)
# => Api::V1::Users::Create
```

### Namespace Formats

#### String Namespace

```ruby
# Various string formats
command_namespace: 'Api::V1::Users'
command_namespace: 'api/v1/users'
command_namespace: 'api.v1.users'
command_namespace: 'api-v1-users'

# All become: Api::V1::Users::
```

#### Array Namespace

```ruby
command_namespace: [:api, :v1, :users]
command_namespace: ['api', 'v1', 'users']
command_namespace: %w[api v1 users]

# All become: Api::V1::Users::
```

#### Hash Namespace

```ruby
# Self-documenting (keys are ignored, values are used in order)
command_namespace: {
  api: :Api,
  version: :V1,
  resource: :Users
}

# Becomes: Api::V1::Users::
```

## Edge Cases and Special Scenarios

### Empty Namespace

```ruby
# No namespace - root level command
SimpleCommandDispatcher.call(command: 'create_user')
# => CreateUser (root level)
```

### Single Module Namespace

```ruby
SimpleCommandDispatcher.call(
  command: :create,
  command_namespace: :users
)
# => Users::Create
```

### Deep Nesting

```ruby
SimpleCommandDispatcher.call(
  command: 'authenticate',
  command_namespace: 'api/auth/v1/providers/oauth'
)
# => Api::Auth::V1::Providers::Oauth::Authenticate
```

### Leading/Trailing Slashes

```ruby
# These are all equivalent
'/api/v1/users/create'
'api/v1/users/create'
'/api/v1/users/create/'
'api/v1/users/create/'

# All become: Api::V1::Users::Create
```

### Multiple Consecutive Separators

```ruby
# Multiple separators are collapsed
'api//v1///users/create'
# => Api::V1::Users::Create

'api::::v1::users'
# => Api::V1::Users
```

## Common Patterns

### RESTful Resource Commands

```ruby
# Standard CRUD operations
'/api/v1/users/create' → Api::V1::Users::Create
'/api/v1/users/update' → Api::V1::Users::Update
'/api/v1/users/destroy' → Api::V1::Users::Destroy
'/api/v1/users/index' → Api::V1::Users::Index
'/api/v1/users/show' → Api::V1::Users::Show
```

### Custom Actions

```ruby
# Beyond CRUD
'/api/v1/users/search' → Api::V1::Users::Search
'/api/v1/users/activate' → Api::V1::Users::Activate
'/api/v1/users/deactivate' → Api::V1::Users::Deactivate
'/api/v1/users/reset_password' → Api::V1::Users::ResetPassword
```

### Nested Resources

```ruby
# Parent/child relationships
'/api/v1/users/123/posts/create'
# Extract the action and namespace separately
# namespace: 'api/v1/users/posts'
# command: 'create'
# => Api::V1::Users::Posts::Create
```

### Versioned APIs

```ruby
# Multiple versions
'/api/v1/search' → Api::V1::Search
'/api/v2/search' → Api::V2::Search
'/api/v3/search' → Api::V3::Search
```

## Debugging Route Mapping

Enable debug mode to see the transformation:

```ruby
SimpleCommandDispatcher.call(
  command: 'api/v1/users/authenticate_user',
  request_params: {},
  options: { debug: true }
)
```

Output:

```
[DEBUG] Begin dispatching command...
[DEBUG] Command: api/v1/users/authenticate_user
[DEBUG] Namespace: {}
[DEBUG] Normalizing: api/v1/users/authenticate_user
[DEBUG] Segments: ["api", "v1", "users", "authenticate_user"]
[DEBUG] Camelized: ["Api", "V1", "Users", "AuthenticateUser"]
[DEBUG] Command to execute: Api::V1::Users::AuthenticateUser
[DEBUG] Constantized command: Api::V1::Users::AuthenticateUser
[DEBUG] End dispatching command
```

## Best Practices

### 1. Be Consistent with Separators

Choose one separator style and stick to it:

```ruby
# Good: Consistent use of /
command: '/api/v1/users/create'
command: '/api/v1/posts/update'

# Avoid: Mixing styles
command: 'api::v1/users.create'  # Confusing!
```

### 2. Match Controller Routes

Make command namespaces match your route structure:

```ruby
# routes.rb
namespace :api do
  namespace :v1 do
    resources :users do
      post :authenticate
    end
  end
end

# Command: app/commands/api/v1/users/authenticate.rb
module Api
  module V1
    module Users
      class Authenticate
        # ...
      end
    end
  end
end
```

### 3. Use Descriptive Names

Command names should clearly indicate their purpose:

```ruby
# Good: Clear intent
'authenticate_user'
'search_mechs_by_tonnage'
'export_users_to_csv'

# Avoid: Ambiguous names
'process'
'handle'
'do_thing'
```

### 4. Leverage request.path in Controllers

In Rails controllers, use `request.path` for automatic mapping:

```ruby
def route_request
  command = SimpleCommandDispatcher.call(
    command: request.path,  # Automatically includes full namespace
    request_params: params
  )
end
```

### 5. Document Unusual Mappings

If you use non-standard mappings, document them:

```ruby
# Unusual mapping - documented
# Route: /api/users/auth maps to Api::Authentication::UserAuth
command = SimpleCommandDispatcher.call(
  command: :user_auth,
  command_namespace: 'api/authentication'
)
```

## Troubleshooting

### Command Not Found Error

```ruby
# Error: InvalidClassConstantError
SimpleCommandDispatcher.call(command: 'api/v1/nonexistent')

# Check:
# 1. Is the file created? app/commands/api/v1/nonexistent.rb
# 2. Is the module/class defined? Api::V1::Nonexistent
# 3. Are the namespaces correct?
```

### Unexpected Class Constant

```ruby
# You expected: Api::V1::Users::Create
# You got: Api::V1::UsersCreate

# Cause: Missing separator
command: 'api/v1/userscreate'  # No separator between 'users' and 'create'

# Fix:
command: 'api/v1/users/create'
```

### Case Sensitivity Issues

```ruby
# File: app/commands/api/v1/users/CreateUser.rb
module Api
  module V1
    module Users
      class CreateUser  # Class name doesn't match Rails conventions
      end
    end
  end
end

# Rails expects snake_case file names:
# File should be: create_user.rb
# Class should be: CreateUser
```

## Summary

Route-to-command mapping in SCD:

1. **Accepts Multiple Formats** - Slashes, colons, hyphens, dots, arrays
2. **Unicode Support** - Handles special characters and whitespace
3. **Flexible Namespacing** - Separate or combined with command
4. **Predictable Transformation** - Uses Rails' proven camelization
5. **Debug Friendly** - Enable debug mode to see transformations

**Key Takeaways:**
- Routes automatically map to class constants
- Be consistent with your separator choice
- Match your directory structure to namespaces
- Use `request.path` in controllers for automatic mapping
- Enable debug mode when troubleshooting

## Next Steps

- [Dynamic Dispatching Patterns](Dynamic-Dispatching.md)
- [Creating Commands](Creating-Commands.md)
- [Troubleshooting Guide](Troubleshooting.md)

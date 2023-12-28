[![Ruby](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml/badge.svg?refresh=1)](https://github.com/gangelo/simple_command_dispatcher/actions/workflows/ruby.yml)
[![GitHub version](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher.svg?refresh=1)](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher)
[![Gem Version](https://badge.fury.io/rb/simple_command_dispatcher.svg?refresh=1)](https://badge.fury.io/rb/simple_command_dispatcher)
[![](https://ruby-gem-downloads-badge.herokuapp.com/simple_command_dispatcher?type=total)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/simple_command_dispatcher/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/simple_command_dispatcher/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

# Q. simple_command_dispatcher - what is it?
# A. It's a Ruby gem!!!

## Overview
__simple_command_dispatcher__ (SCD) allows you to execute __simple_command__ commands (and now _custom commands_ as of version 1.2.1) in a more dynamic way. If you are not familiar with the _simple_command_ gem, check it out [here][simple-command]. SCD was written specifically with the [rails-api][rails-api] in mind; however, you can use SDC wherever you would use simple_command commands. 

## Update as of Version 1.2.1
### Custom Commands
SCD now allows you to execute _custom commands_ (i.e. classes that do not prepend the _SimpleCommand_ module) by setting `Configuration#allow_custom_commands = true` (see the __Custom Commands__ section below for details).

## Example
The below example is from a `rails-api` API that uses token-based authentication and services two mobile applications, identified as *__my_app1__* and *__my_app2__*, in this example.

This example assumes the following:

* `application_controller` is a base class, inherited by all other controllers. The `#authenticate_request` method is called for every request in order to make sure the request is authorized (`before_action :authenticate_request`).
* `request.headers` will contain the authorization token to authorize all requests (`request.headers["Authorization"]`)
* This application uses the following folder structure to manage its _simple_command_ commands:

![N|Solid](https://cldup.com/1UeyWzOLic.png)

Command classes (and the modules they reside under) are named *__according to their file name and respective location within the above folder structure__*; for example, the command class defined in the `/api/my_app1/v1/authenticate_request.rb` file would be defined in this manner:

```ruby 
# /api/my_app1/v1/authenticate_request.rb

module Api 
   module MyApp1 
      module V1 
         class AuthenticateRequest 
         end 
     end 
   end 
end
```
   
Likewise, the command class defined in the `/api/my_app2/v2/update_user.rb` file would be defined in this manner, and so on:

```ruby 
# /api/my_app2/v2/update_user.rb

module Api 
   module MyApp2 
      module V2 
         class UpdateUser 
         end 
     end 
   end 
end
```

The __routes used in this example__, conform to the following format: `"/api/[app_name]/[app_version]/[controller]"` where `[app_name]` = the _application name_,`[app_version]` = the _application version_, and `[controller]` = the _controller_; therefore, running `$ rake routes` for this example would output the following sample route information:


| Prefix        | Verb | URI Pattern | Controller#Action |
|-------------:|:-------------|:------------------|:------------------|
| api_my_app1_v1_user_authenticate | POST  | /api/my_app1/v1/user/authenticate(.:format) | api/my_app1/v1/authentication#create |
| api_my_app1_v2_user_authenticate | POST  | /api/my_app1/v2/user/authenticate(.:format) | api/my_app1/v2/authentication#create |
| api_my_app2_v1_user_authenticate | POST  | /api/my_app2/v1/user/authenticate(.:format) | api/my_app2/v1/authentication#create |
| api_my_app2_v2_user              | PATCH | /api/my_app2/v2/users/:id(.:format)         | api/my_app2/v2/users#update |
|                                  | PUT   | /api/my_app2/v2/users/:id(.:format)         | api/my_app2/v2/users#update |


### Request Authentication Code Snippet

```ruby
# /config/initializers/simple_command_dispatcher.rb

# See: http://pothibo.com/2013/07/namespace-stuff-in-your-app-folder/

=begin
# Uncomment this code if you want to namespace your commands in the following manner, for example:
#
#   class Api::MyApp1::V1::AuthenticateRequest; end
#
# As opposed to this: 
# 
#   module Api
#      module MyApp1
#         module V1
#            class AuthenticateRequest
#            end
#         end
#     end
#   end
#
module Helpers
   def self.ensure_namespace(namespace, scope = "::")
      namespace_parts = namespace.split("::")

      namespace_chain = ""

      namespace_parts.each { | part |
         namespace_chain = (namespace_chain.empty?) ? part : "#{namespace_chain}::#{part}"
         eval("module #{scope}#{namespace_chain}; end")
      }
   end
end

Helpers.ensure_namespace("Api::MyApp1::V1")
Helpers.ensure_namespace("Api::MyApp1::V2")
Helpers.ensure_namespace("Api::MyApp2::V1")
Helpers.ensure_namespace("Api::MyApp2::V2")
=end

# simple_command_dispatcher creates commands dynamically; therefore we need
# to make sure the namespaces and command classes are loaded before we construct and
# call them. The below code traverses the 'app/api' and all subfolders, and
# autoloads them so that we do not get any NameError exceptions due to
# uninitialized constants.
Rails.application.config.to_prepare do
   path = Rails.root + "app/api"
   ActiveSupport::Dependencies.autoload_paths -= [path.to_s]

   reloader = ActiveSupport::FileUpdateChecker.new [], path.to_s => [:rb] do
      ActiveSupport::DescendantsTracker.clear
      ActiveSupport::Dependencies.clear

      Dir[path + "**/*.rb"].each do |file|
         ActiveSupport.require_or_load file
      end
   end

   Rails.application.reloaders << reloader
   ActionDispatch::Reloader.to_prepare { reloader.execute_if_updated }
   reloader.execute
end

# Optionally set our configuration setting to allow
# for custom command execution.
SimpleCommand::Dispatcher.configure do |config|
   config.allow_custom_commands = true
end 
```

```ruby 
# /app/controllers/application_controller.rb

require 'simple_command_dispatcher'

class ApplicationController < ActionController::API
   before_action :authenticate_request
   attr_reader :current_user

   protected

   def get_command_path
      # request.env['PATH_INFO'] could return any number of paths. The important
      # thing (in the case of our example), is that we get the portion of the 
      # path that uniquely identifies the SimpleCommand we need to call; this 
      # would include the application, the API version and the SimpleCommand
      # name itself.
      command_path = request.env['PATH_INFO'] # => "/api/[app name]/v1/[action]”
      command_path = command_path.split('/').slice(0,4).join('/') # => "/api/[app name]/v1/"
   end

   private
   
   def authenticate_request
      # The parameters and options we are passing to the dispatcher, wind up equating
      # to the following: Api::MyApp1::V1::AuthenticateRequest.call(request.headers).
      # Explaination: @param command_modules (e.g. path, "/api/my_app1/v1/"), in concert with @param 
      # options { camelize: true }, is transformed into "Api::MyApp1::V1" and prepended to the 
      # @param command, which becomes "Api::MyApp1::V1::AuthenticateRequest." This string is then
      # simply constantized; #call is then executed, passing the @param command_parameters
      # (e.g. request.headers, which contains ["Authorization"], out authorization token).
      # Consequently, the correlation between our routes and command class module structure 
      # was no coincidence.
      command = SimpleCommand::Dispatcher.call(:AuthenticateRequest, get_command_path, { camelize: true}, request.headers)
      if command.success?
         @current_user = command.result
      else
         render json: { error: 'Not Authorized' }, status: 401
      end
    end
end
```

## Custom Commands

As of __Version 1.2.1__ simple_command_dispatcher (SCD) allows you to execute _custom commands_ (i.e. classes that do not prepend the _SimpleCommand_ module) by setting `Configuration#allow_custom_commands = true`.

In order to execute _custom commands_, there are three (3) requirements:
   1. Create a _custom command_. Your _custom command_ class must expose a public `::call` class method.
   2. Set the `Configuration#allow_custom_commands` property to `true`.
   3. Execute your _custom command_ by calling the `::call` class method. 

### Custom Command Example

#### 1. Create a Custom Command
```ruby
# /api/my_app/v1/custom_command.rb

module Api
   module MyApp
         module V1

            # This is a custom command that does not prepend SimpleCommand.
            class CustomCommand
               
               def self.call(*args)
                  command = self.new(*args)
                  if command
                     command.send(:execute)
                  else
                     false
                  end
               end
               
               private

               def initialize(params = {})
                  @param1 = params[:param1]
               end

               private

               attr_accessor :param1

               def execute
                  if (param1 == :param1)
                     return true
                  end

                  return false
               end
            end

      end
   end
end
```
#### 2. Set the `Configuration#allow_custom_commands` property to `true`
```ruby
# In your rails, rails-api app, etc...
# /config/initializers/simple_command_dispatcher.rb

SimpleCommand::Dispatcher.configure do |config|
    config.allow_custom_commands = true
end 
```

#### 3. Execute your _Custom Command_
Executing your _custom command_ is no different than executing a __SimpleCommand__ command with the exception that you must properly handle the return object that results from calling your _custom command_; being a _custom command_, there is no guarantee that the return object will be the command object as is the case when calling a SimpleCommand command.
```ruby
# /app/controllers/some_controller.rb

require 'simple_command_dispatcher'

class SomeController < ApplicationController::API
   public
   
   def some_api
      success = SimpleCommand::Dispatcher.call(:CustomCommand, get_command_path, { camelize: true}, request.headers)
      if success
         # Do something...
      else
         # Do something else...
      end
    end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_command_dispatcher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_command_dispatcher

## Usage

See the example above.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gangelo/simple_command_dispatcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

   [simple-command]: <https://rubygems.org/gems/simple_command>
   [rails-api]: <https://rubygems.org/gems/rails-api>


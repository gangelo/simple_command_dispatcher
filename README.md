[![GitHub version](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher.svg)](https://badge.fury.io/gh/gangelo%2Fsimple_command_dispatcher)
[![Gem Version](https://badge.fury.io/rb/simple_command_dispatcher.svg)](https://badge.fury.io/rb/simple_command_dispatcher)

# Q. simple_command_dispatcher - what is it?
# A. It's a Ruby gem!

## Overview
__simple_command_dispatcher__ (SCD) allows you to execute __simple_command__ commands in a more dynamic way. If you are not familiar with the _simple_command_ gem, check it out [here][simple-command]. SCD was written specifically with the [rails-api][rails-api] in mind; however, you can use SDC wherever you use simple_command commands. 

## Example
The below example is from a `rails-api` API that uses token-based authentication and services two mobile applications, identified as *__my_app1__* and *__my_app2__*, in this example.

This example assumes the following:

* `application_controller` is a base class, inherited by all other controllers. The `#authenticate_request` method is called for every request in order to make sure the request is authorized (`before_action :authenticate_request`).
* `request.headers` will contain the authorization token to authorize all requests (`request.headers["Authorization"]`)
* This application uses the following folder structure to manage its _simple_command_ commands:

![N|Solid](https://cldup.com/1UeyWzOLic.png)

 * Command classes (and the modules they reside under) are named *__according to their file name and respective location within the above folder structure__*; therefore, the command classes defined for this example would be named in the following manner:
   * `'/api/my_app1/v1/authenticate_request.rb' # => class Api::MyApp1::V1::AuthenticateRequest ... end`
   * `'/api/my_app1/v1/authenticate_user.rb’ # => class Api::MyApp1::V1::AuthenticateUser ... end`
   * `‘/api/my_app1/v2/authenticate_user.rb’ # => class Api::MyApp1::V2::AuthenticateUser ... end`
   * `'/api/my_app2/v1/authenticate_request.rb’ # => class Api::MyApp2::V1::AuthenticateRequest ... end`
   * `'/api/my_app2/v1/authenticate_user.rb’ # => class Api::MyApp2::V1::AuthenticateUser ... end`
   * `‘/api/my_app2/v1/update_user.rb’ # => class Api::MyApp2::V1::UpdateUser ... end`
   * `‘/api/my_app2/v2/update_user.rb’ # => class Api::MyApp2::V2::UpdateUser ... end`

* The *__routes used in this example__*, conform to the following format: `"/api/[app_name]/[app_version]/[controller]"` where `[app_name]` = the _application name_,`[app_version]` = the _application version_, and `[controller]` = the _controller_; therefore, running `$ rake routes` for this example would output the following sample route information:

| Prefix        | Verb | URI Pattern | Controller#Action 
|-------------:|:-------------|:------------------|:------------------|
| api_**my_app1_v1**_user_authenticate | POST  | /api/**my_app1/v1**/user/authenticate(.:format) | api/**my_app1/v1**/authentication#create |
| api_**my_app1_v2**_user_authenticate | POST  | /api/**my_app1/v2**/user/authenticate(.:format) | api/**my_app1/v2**/authentication#create |
| api_**my_app2_v1**_user_authenticate | POST  | /api/**my_app2/v1**/user/authenticate(.:format) | api/**my_app2/v1**/authentication#create |
| api_**my_app2_v2**_user | PATCH | /api/**my_app2/v2**/users/:id(.:format) | api/**my_app2/v2**/users#update |
|  | PUT | /api/**my_app2/v2**/users/:id(.:format) | api/**my_app2/v2**/users#update |

### Request Authentication Code Snippet


```ruby 
# /app/controllers/application_controller.rb
require 'simple_command_dispatcher'

class ApplicationController < ActionController::API
    before_action :authenticate_request
    attr_reader :current_user

    private

    def authenticate_request
        # request.env['PATH_INFO'] could return any number of paths. The important
        # thing (in the case of our example), is that we get the portion of the 
        # path that uniquely identifies the SimpleCommand we need to call; this 
        # would include the application, the API version and the SimpleCommand
        # name itself.
        path = request.env['PATH_INFO'] # => "/api/my_app1/v1/user_create”
        path = route.split('/').slice(0,4).join('/') # => "/api/my_app1/v1/"
        
        # The parameters and options we are passing to the dispatcher, wind up equating
        # to the following: Api::MyApp1::V1::AuthenticateRequest.call(request.headers).
        # Explaination: @param command_modules (e.g. path, "/api/my_app1/v1/"), in concert with @param 
        # options { camelize: true }, is transformed into "Api::MyApp1::V1" and prepended to the 
        # @param command, which becomes "Api::MyApp1::V1::AuthenticateRequest." This string is then
        # simply constantized; #call is then executed, passing the @param command_parameters
        # (e.g. request.headers, which contains ["Authorization"], out authorization token).
        # Consequently, the correlation between our routes and command class module structure 
        # was no coincidence.
        command = SimpleCommand::Dispatcher.call(:AuthenticateRequest, 
                     path, { camelize: true}, request.headers)
        if command.success?
            @current_user = command.result
        else
            render json: { error: 'Not Authorized' }, status: 401
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


# Q. simple_command_dispatcher - what is it?
# A. It's a Ruby gem!

## Overview
__simple_command_dispatcher__ (SCD) allows you to execute __simple_command__ commands in a more dynamic way. If you are not familiar with the _simple_command_ gem, check it out [here][simple-command]. SCD was written specifically with the [rails_api][rails-api] in mind; however, you can use SDC wherever you use simple_command commands. 

## Example
The below example is from a `rails-api` API that uses token-based authentication, and assumes the following:

* `application_controller` is a base class, inherited by all other controllers. The `#authenticate_request` action is called with every request for authentication (`before_action :authenticate_request`).
* `request.headers` will contain the authorization token to authenticate the request (`request.headers["Authorization"]`)
* This application uses the following folder structure to manage its _simple_command_ commands:

![N|Solid](https://cldup.com/EJsj-OKZy0.png)

(example cont.)

 * The command classes are named *__according to their respective location within the above folder structure__*.
 * The route format necessary to authenticate a request takes on the following format: `"/api/[app_name]/[app_version]/authenticate"` where `[app_name]` = the _application name_, and `[app_version]` = the _application version_.
* The classes within each `authenticate.rb` file in the above folder structure would `prepend SimpleCommand` and be named the following:
  * ```'/api/my_app1/v1/authenticate.rb’ # => class Api::MyApp1::V1::Authenticate ... end```
  * ```‘/api/my_app1/v2/authenticate.rb’ # => class Api::MyApp1::V2::Authenticate ... end```
  * ```‘/api/my_app2/v1/authenticate.rb’ # => class Api::MyApp2::V1::Authenticate ... end```
  * ```‘/api/my_app2/v2/authenticate.rb’ # => class Api::MyApp2::V2::Authenticate ... end```
* The 

```ruby 
# /app/controllers/application_controller.rb
require 'simple_command_dispatcher'

class ApplicationController < ActionController::API
   before_action :authenticate_request
   attr_reader :current_user

   private

   def authenticate_request
      @current_user = AuthorizeApiRequest.call(request.headers).result
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simple_command_dispatcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

   [simple-command]: <https://rubygems.org/gems/simple_command>
   [rails-api]: <https://rubygems.org/gems/rails-api>


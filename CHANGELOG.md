### Version 1.2.3
* Refactor 'requires' in configure.rb and simple_command_dispatcher.rb
* Update gemspec summary and description
### Version 1.2.2
* Bug fix
  * Fixed NoMethodError on 'configure' metnod when trying to include configuration block in /config/initializers/simple_command_dispatcher.rb
### Version 1.2.1
* Configuration class
  * Added the new Configuration class that exposes the #allow_custom_classes property which takes a Boolean allowing/disallowing the use of custom commands to be used. See the documentation for details and usage.
* Custom commands
  * Allow ability for users to use custom commands (i.e. classes that do not prepend the SimpleCommand module) as long as the command class respond_to? the ::call public class method. Note: Configuration#allow_custom_commands must be set to true to use custom commands.
* Documentation updates
  * Add documentation for new Configuration class and miscellaneous other code additions/changes.

### Version 1.1.1
* Documentation updates
  * Add example code in README.md to include clarification on command namespacing, and how to autoload command classes to avoid NameError exceptions when SimpleCommand::Dispatcher.call(...) is call due to uninitialized command constants.

## Version 1.1.0 - 2016-11-01 [YANKED]
## Version 1.0.0 - 2016-11-01 [YANKED]
## Version 0.2.0 - 2016-11-01 [YANKED]
## Version 0.1.3 - 2016-11-01 [YANKED]
## Version 0.1.2 - 2016-10-29 [YANKED]
## Version 0.1.1 - 2016-10-29 [YANKED]
## Version 0.1.0 - 2016-10-29 [YANKED]

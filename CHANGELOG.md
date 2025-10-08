# CHANGELOG

## Version 4.2.0 - 2025-10-07

- **New Feature: Configurable Logger with Debug Mode**:

  - Added configurable logger with automatic Rails.logger detection
  - Introduced debug mode for command execution debugging via `options: { debug: true }`
  - Logger can be configured via `SimpleCommandDispatcher.configuration.logger`
  - Added `OptionsService` for managing command execution options
  - Enhanced `SimpleCommandDispatcher.call` with `options:` parameter to support debug logging
  - When debug mode is enabled, detailed debug logging shows command execution flow

- **Test Coverage Improvements**:

  - Achieved 100% test coverage across all modules (243 examples, 0 failures)
  - Added comprehensive tests for `CommandCallable::Errors` class (15 new tests)
  - Added comprehensive tests for `CommandCallable::Utils.array_wrap` method (8 new tests)
  - Added tests for Rails logger auto-detection in configuration
  - Added tests for debug mode functionality in command execution
  - Enhanced test coverage for `OptionsService` and logger integration

- **Documentation Enhancements**:

  - Updated API documentation for `SimpleCommandDispatcher.call` to include `options` parameter
  - Added comprehensive documentation for `CommandCallable` module with usage examples
  - Documented all public methods in `Errors` class with examples
  - Added documentation for `OptionsService` class and debug mode
  - Enhanced `Configuration` documentation to include logger attribute
  - Fixed all YARD documentation to accurately reflect current implementation
  - Added best practice guidance for private `initialize` in CommandCallable commands

- **Dependency Updates**:

  - Added `irb` and `reline` gems to development dependencies
  - Addresses Ruby 3.5 deprecation warnings for extracted standard library gems
  - Rails 8 compatibility confirmed (supports ActiveSupport 8.x)

## Version 4.1.0 - 2025-07-14

- **New Feature: CommandCallable Module**:
  
  - Introduced `SimpleCommandDispatcher::Commands::CommandCallable` module for standardizing command classes
  - Provides automatic `.call` class method generation that instantiates and calls your command
  - Built-in success/failure tracking with `success?` and `failure?` methods based on error state
  - Automatic result tracking - command return values stored in `command.result`
  - Consistent error handling with built-in `errors` object for error collection and management
  - Call tracking to ensure methods work correctly and commands are properly executed
  - Completely optional but recommended for building robust, maintainable commands

- **Enhanced Documentation**:

  - Major README.md overhaul with real-world examples showcasing dynamic command execution
  - Added comprehensive examples demonstrating convention over configuration approach
  - Included versioned API command examples (V1 vs V2) showing practical usage patterns
  - Added controller examples showing how to use `request.path` and `params` for dynamic routing
  - Enhanced payment processing example with proper error handling and rescue patterns
  - Added efficient database query examples using ActiveRecord scopes
  - Improved parameter handling documentation showing kwargs vs single hash approaches
  - Added alternative command splitting approach for more granular control
  - Updated all examples to use `command` variable instead of `result` for clarity
  - Added custom command guidance for users who prefer to roll their own implementations

## Version 4.0.0 - 2025-07-12

- **Documentation Overhaul**:

  - Completely rewrote README.md with modern examples and comprehensive Rails integration guides
  - Fixed documentation accuracy issues across all modules and classes
  - Corrected method signatures and parameter types in YARD documentation
  - Updated all examples to use keyword arguments and match current implementation
  - Added comprehensive documentation for helper methods and error classes
  - Added migration guide from v3.x to v4.x with breaking change explanations
  - Included advanced usage patterns (route-based dispatch, batch execution, dynamic versioning)

- **Test Coverage Enhancements**:

  - Added comprehensive test suite for `CommandNamespaceService` (previously untested)
  - Replaced placeholder tests with full implementations for `Camelize` and `TrimAll` helpers
  - Added thorough test coverage for `Kernel#eigenclass` extension
  - Created direct unit tests for custom error classes with edge case testing
  - Improved overall test coverage with real-world scenarios and Unicode support
  - Added extensive edge case testing for input validation and error conditions

- **Helper Method Improvements**:

  - Enhanced `Camelize` helper to better handle RESTful route conversion to Ruby constants
  - Improved `TrimAll` helper with Unicode whitespace support using `\p{Space}` regex
  - Added robust error handling and edge case management for various input types
  - Optimized performance for route-to-constant transformations using Rails' proven methods
  - Better handling of mixed separators (hyphens, dots, spaces, colons)

- **Code Quality & Tooling**:

  - Fixed RuboCop configuration errors (typo in `plugins`, removed deprecated `RSpec/NotToNot`)
  - Added proper `RSpec/NestedGroups` configuration
  - All RuboCop checks now pass with zero offenses
  - Improved code organization and consistency

- **Breaking Changes**:
  - Minimum ruby version changed from 3.0.1 to 3.3
  - Removed dependency on `simple_command` gem for lighter footprint
  - Removed `allow_custom_commands` configuration option (all commands are now "custom")
  - `SimpleCommandDispatcher.call` method signature changed to accept keyword arguments: `command:`, `command_namespace:`, and `request_params:`
  - Changed gem namespace from `SimpleCommand::Dispatcher` to `SimpleCommandDispatcher`
  - Removed `options:` parameter and all camelization options (camelization is now automatic)
  - Fixed duplicate `Errors` namespacing on error classes under `SimpleCommandDispatcher::Errors`

## Version 3.0.3 - 2024-08-03

- Update Ruby gems.
- Patch CVE related to `rexml` gem.

## Version 3.0.3 - 2024-02-18

- Update Ruby gems.

## Version 3.0.2 - 2024-01-31

- Update Ruby gems.

## Version 3.0.1 - 2024-01-07

- Relax Ruby version requirement to `>= 3.0.1`, `< 4.0`.
- Update Ruby gems.

## Version 3.0.0 - 2023-12-27

- Now requires Ruby `>= 3.0`.
- Now requires `simple_command` `~> 1.0`, `>= 1.0.1`.
  - Note: Attempting to remove this dependency for users not using `simple_command`.
- Update Ruby gems.

## Version 2.0.1 - 2023-12-02

- Update Ruby gems.

## Version 2.0.0 - 2023-11-01

- `simple_command_dispatcher` now depends on Ruby `>= 2.7.0`.
- Update Ruby gems.

## Version 1.2.8 - 2023-08-30

- Update Ruby gems.

## Version 1.2.7

- Update Ruby gems.
- Miscellaneous refactors.

## Version 1.2.6

- Update Ruby gems to patch CVE.

## Version 1.2.5

- Check in `Gemfile.lock`.

## Version 1.2.4

- Now requires Ruby `2.6.3`.
- Fix broken spec.
- Update Ruby gems.
- Patch CVEs:
  - `activesupport` (CVE-2020-8165)
  - `rake` (CVE-2020-8130)
  - `rdoc` (CVE-2021-31799)
  - `tzinfo` (CVE-2022-31163)
  - `yard` (CVE-2017-17042, CVE-2019-1020001).
- Fix RuboCop violations.

## Version 1.2.3

- Refactor `requires` in `configure.rb` and `simple_command_dispatcher.rb`.
- Update gemspec summary and description.

## Version 1.2.2

- **Bug Fix**:
  - Fixed `NoMethodError` in `configure` method when trying to include configuration block in `/config/initializers/simple_command_dispatcher.rb`.

## Version 1.2.1

- **Configuration Class**:
  - Added the new `Configuration` class exposing the `#allow_custom_classes` property.
  - Allows/disallows the use of custom commands. See documentation for details and usage.
- **Custom Commands**:
  - Allow users to use custom commands (i.e., classes that do not prepend the `SimpleCommand` module).
  - Commands must respond to the `::call` public class method.
  - Note: `Configuration#allow_custom_commands` must be set to `true` to use custom commands.
- **Documentation Updates**:
  - Added documentation for the new `Configuration` class and miscellaneous other code additions/changes.

## Version 1.1.1

- **Documentation Updates**:
  - Added example code in `README.md` to clarify command namespacing and how to autoload command classes.
  - Helps avoid `NameError` exceptions when `SimpleCommandDispatcher.call(...)` is invoked due to uninitialized command constants.

## [YANKED VERSIONS]

- **Version 1.1.0** - 2016-11-01
- **Version 1.0.0** - 2016-11-01
- **Version 0.2.0** - 2016-11-01
- **Version 0.1.3** - 2016-11-01
- **Version 0.1.2** - 2016-10-29
- **Version 0.1.1** - 2016-10-29
- **Version 0.1.0** - 2016-10-29

# CHANGELOG

## Version 4.0.0 - 2025-07-10

- Update code documentation.

- **Breaking Change**:
  - Minimum ruby version changed from 3.0.1 to 3.1.0.
  - Remove dependency on `simple_command` gem.
  - Remove `allow_custom_commands` configuration option as it's unnecessary due to the aforementioned.
  - `SimpleCommandDispatcher.call` method signature changed to accept keyword arguments that are more descriptive: `command:`, `command_namespace:`, and `request_params:` respectively.
  - Changed/combined gem namespaces from `SimpleCommand::Dispatcher` to `SimpleCommandDispatcher`.
  - `SimpleCommandDispatcher.call`: keyword argument `options:` has been removed (i.e. options `camelize`, `class_camelize`, `module_camelize`, `titleize`, `class_titleize`, `module_titleize` are unnecessary, as `camelize` is now called unconditionally on the `command` and `command_namespace`.
  - Removed duplicate `Errors` namespacing on error classes under `SimpleCommandDispatcher::Errors`.

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

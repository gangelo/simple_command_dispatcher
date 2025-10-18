# Welcome to the simple_command_dispatcher Wiki!

**simple_command_dispatcher** (SCD) is a lightweight Ruby gem that enables Rails applications to dynamically execute command objects using convention over configuration. It automatically transforms request paths into Ruby class constants, allowing controllers to dispatch commands based on routes and parameters.

## Quick Links

### Getting Started
- [Installation Guide](Installation.md) - Set up the gem in your project
- [Quick Start Tutorial](Quick-Start.md) - Build your first command in 5 minutes
- [Core Concepts](Core-Concepts.md) - Understand how SCD works

### Building Commands
- [Creating Commands](Creating-Commands.md) - Learn to write command classes
- [CommandCallable Module](CommandCallable-Module.md) - Standardize your commands with built-in tracking
- [Parameter Handling](Parameter-Handling.md) - Master different parameter types
- [Error Handling](Error-Handling.md) - Handle errors gracefully

### Advanced Topics
- [Route-to-Command Mapping](Route-to-Command-Mapping.md) - Deep dive into convention over configuration
- [Dynamic Dispatching](Dynamic-Dispatching.md) - Advanced controller patterns
- [Versioning API Commands](Versioning-API-Commands.md) - Manage multiple API versions
- [Configuration & Logging](Configuration-and-Logging.md) - Customize SCD behavior

### Real-World Examples
- [Authentication Example](Examples-Authentication.md) - User login/authentication
- [Payment Processing Example](Examples-Payment-Processing.md) - Handling payments
- [API Search Example](Examples-API-Search.md) - Building search endpoints
- [CRUD Operations](Examples-CRUD.md) - Standard CRUD patterns

### Reference
- [API Reference](API-Reference.md) - Complete method and class documentation
- [Migration Guide](Migration-Guide.md) - Upgrading from v3.x to v4.x
- [Troubleshooting](Troubleshooting.md) - Common issues and solutions
- [FAQ](FAQ.md) - Frequently asked questions

## Why simple_command_dispatcher?

### The Problem
Controllers get bloated with business logic. Service objects help, but you still need boilerplate routing code.

### The Solution
SCD automatically maps request paths to commands—**zero configuration needed**:

```ruby
# Your request:
POST /api/v1/mechs/search

# SCD automatically calls:
Api::V1::Mechs::Search.call(params)
```

No routing tables. No switch statements. No manual mapping. **Just convention.**

### Key Benefits

✅ **Convention Over Configuration** - Paths automatically map to commands
✅ **Built-in Success/Failure Tracking** - Know instantly if your command worked
✅ **Dynamic Dispatching** - One controller action handles multiple commands
✅ **Smart Parameter Handling** - Works with Hash, Array, or single values
✅ **Lightweight** - Only one dependency (ActiveSupport)
✅ **Fast** - Uses Rails' proven camelization under the hood

## Demo Application

See SCD in action with the [demo application](https://github.com/gangelo/simple_command_dispatcher_demo_app) - a complete Rails API app with tests demonstrating real-world usage.

## Getting Help

- **Documentation:** You're in the right place!
- **Issues:** [Report bugs on GitHub](https://github.com/gangelo/simple_command_dispatcher/issues)
- **RubyDoc:** [API Documentation](http://www.rubydoc.info/gems/simple_command_dispatcher/)

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/gangelo/simple_command_dispatcher). This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

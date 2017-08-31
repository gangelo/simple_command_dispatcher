$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "simple_command_dispatcher"
require "simple_command_dispatcher/klass_transform"
require "simple_command_dispatcher/configuration"
require "simple_command_dispatcher/configure"

require "api/app_name/v1/test_command"
require "api/app_name/v2/test_command"
require "api/app_name/v1/invalid_command"
require "api/app_name/v1/custom_command"
require "api/app_name/v2/invalid_custom_command"

require "api/no_qualifiers_command"
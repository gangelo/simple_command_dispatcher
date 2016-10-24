$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "simple_command_dispatcher"
require "api/app_name/v1/test_command"
require "api/app_name/v1/invalid_command"
require "api/app_name/v1/warning_command"
# frozen_string_literal: true

require 'pry-byebug'
require 'simple_command_dispatcher'

Dir[File.join(Dir.pwd, "spec/api/**/*.rb")].each {|f| require f}

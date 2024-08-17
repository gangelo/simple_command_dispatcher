# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Rspec
RSpec::Core::RakeTask.new(:spec)
#task default: :spec

# Load our custom rake tasks.
Gem.find_files('tasks/**/*.rake').each { |path| import path }

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[spec rubocop]

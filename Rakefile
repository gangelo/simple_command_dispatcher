# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

# Rspec
RSpec::Core::RakeTask.new(:spec)
#task default: :spec

# Yard
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--no-cache', '--protected', '--private']
  t.stats_options = ['--list-undoc']
end

# Load our custom rake tasks.
Gem.find_files('tasks/**/*.rake').each { |path| import path }

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[spec rubocop]

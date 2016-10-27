require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

# Rspec
RSpec::Core::RakeTask.new(:spec)
task default: :spec


# Yard
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   
  t.options = ['--no-cache', '--protected', '--private', '--embed-mixins', '--markup MARKDOWN'] 
  t.stats_options = ['--list-undoc'] 
end

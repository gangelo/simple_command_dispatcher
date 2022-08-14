# frozen_string_literal: true

require 'rake'
# Tasks to play with certain klass_transform module members

desc 'Test to_class_string'
task :to_class_string do
  require 'colorize'
  require 'simple_command_dispatcher'

  class Test
    prepend SimpleCommand::KlassTransform
  end

  puts "Testing SimpleCommand::KlassTransform#to_class_String...\n".cyan
  puts 'Enter a blank line to exit.'.cyan
  loop do
    puts "\nUsage: \"-c [class], -o [options]\" where class = String or Symbol and options = Hash".cyan
    puts "\n\t Examples:"
    print "\n\t\t-c \"my_class\" -o { class_camelize: true }".cyan
    print "\n\t\t-c :MyClass -o { class_camelize: false }".cyan

    print "\n=> "

    input = $stdin.gets.chomp
    break if input.empty?

    input = clean_input(input)

    klass = get_option_class(input)
    if klass.nil? || klass.empty?
      print "=> Error: Class not a String or Symbol\n".red
      next
    elsif !klass.is_a?(String) && !klass.is_a?(Symbol)
      print "=> Error: Class not a String or Symbol\n".red
      next
    end

    options_hash = get_options_hash(input)

    options_hash = { class_camelize: true }.merge(options_hash || {})

    puts "\nCalling to_class_string with the following parameters: class: #{klass.class}, options: #{options_hash.class}".cyan

    print "\nSuccess: => #to_class_String(#{klass}, #{options_hash}) => #{Test.new.to_class_string(klass,
                                                                                                   options_hash)}\n".green
  end

  print
  print 'Done'.yellow
  print
end

desc 'Test to_modules_string'
task :to_modules_string do
  require 'colorize'
  require 'simple_command_dispatcher'

  class Test
    prepend SimpleCommand::KlassTransform
  end

  puts "Testing SimpleCommand::KlassTransform#to_modules_string...\n".cyan
  puts 'Enter a blank line to exit.'.cyan
  loop do
    puts "\nUsage: \"-m [modules], -o [options]\" where modules = Hash, Array or String and options = Hash".cyan
    puts "\n\t Examples:"
    print "\n\t\t-m \"Module1::Module2::Module3\" -o { modules_camelize: false }".cyan
    print "\n\t\t-m [:module1, :module2, :module3] -o { modules_camelize: true }".cyan
    print "\n\t\t-m {api: :api, app: :crazy_buttons, version: :v1} -o { modules_camelize: true }".cyan

    print "\n=> "

    input = $stdin.gets.chomp
    break if input.empty?

    input = clean_input(input)

    modules = get_option_modules(input)
    p modules.class
    if modules.nil? || modules.empty?
      print "=> Error: Modules not a Hash, Array or String\n".red
      next
    elsif !modules.is_a?(Hash) && !modules.is_a?(Array) && !modules.is_a?(String)
      print "=> Error: Modules not a Hash, Array or String\n".red
      next
    end

    options_hash = get_options_hash(input)
    options_hash = { module_camelize: true }.merge(options_hash || {})

    puts "\nCalling to_modules_string with the following parameters: modules: #{modules}, type: #{modules.class}, options: #{options_hash}, type: #{options_hash.class}...".cyan

    puts "\nSuccess: => #to_modules_string(#{modules}, #{options_hash}) => #{Test.new.to_modules_string(modules,
                                                                                                        options_hash)}\n".green
  end

  print
  print 'Done'.yellow
  print
end

desc 'Test to_constantized_class_string'
task :to_constantized_class_string do
  require 'colorize'
  require 'simple_command_dispatcher'

  class Test
    prepend SimpleCommand::KlassTransform
  end

  puts "Testing SimpleCommand::KlassTransform#to_constantized_class_string...\n".cyan
  puts 'Enter a blank line to exit.'.cyan
  loop do
    puts "\nUsage: \"-c [class] -m [modules], -o [options]\" where class = Symbol or String, modules = Hash, Array or String and options = Hash".cyan
    puts "\n\t Examples:"
    print "\n\t\t-c :MyClass -m \"Module1::Module2::Module3\" -o { modules_camelize: false }".cyan
    print "\n\t\t-c \"my_class\" -m [:module1, :module2, :module3] -o { modules_camelize: true }".cyan
    print "\n\t\t-c :myClass -m {api: :api, app: :crazy_buttons, version: :v1} -o { modules_camelize: true }".cyan

    print "\n=> "

    input = $stdin.gets.chomp
    break if input.empty?

    input = clean_input(input)

    klass = get_option_class(input)
    if klass.nil? || klass.empty?
      print "=> Error: Class not a String or Symbol\n".red
      next
    elsif !klass.is_a?(String) && !klass.is_a?(Symbol)
      print "=> Error: Class not a String or Symbol\n".red
      next
    end

    modules = get_option_modules(input)
    if modules.nil? || modules.empty?
      print "=> Error: Modules not a Hash, Array or String\n".red
      next
    elsif !modules.is_a?(Hash) && !modules.is_a?(Array) && !modules.is_a?(String)
      print "=> Error: Modules not a Hash, Array or String\n".red
      next
    end

    options_hash = get_options_hash(input)
    options_hash = { class_camelize: true, module_camelize: true }.merge(options_hash || {})

    puts "\nCalling to_constantized_class_string with the following parameters: class: #{klass}, type: #{klass.class}, modules: #{modules}, type: #{modules.class}, options: #{options_hash}, type: #{options_hash.class}...".cyan

    puts "\nSuccess: => #to_constantized_class_string(#{klass}, #{modules}, #{options_hash}) => #{Test.new.to_constantized_class_string(
      klass, modules, options_hash
    )}\n".green
  end

  print
  print 'Done'.yellow
  print
end

#
# Helper methods
#

def clean_input(input)
  # Place a space before every dash that is not separated by a space.
  input = input.gsub(/-c/, ' -c ').gsub(/-m/, ' -m ').gsub(/-o/, ' -o ')
  input = input.gsub(/"/, ' " ').gsub(/\s+/, ' ').strip

  puts "=> keyboard input after clean_input => #{input}".magenta

  input
end

def get_option_class(options)
  return '' if options.nil? || options.empty?

  options_options = options[/-c\s*([:"].+?(["\s-]||$?))($|\s+|-)/m, 1]

  return '' if options_options.nil?

  options_options = options_options.gsub(/("|')+/, '')
  klass = options_options.strip.gsub(/\s+/, ' ')

  puts "=> class after get_option_class => #{klass}".magenta

  klass
end

def get_options_hash(options)
  return {} if options.nil? || options.empty?

  options_options = options[/-o\s*([{].+?([}\s-]$?))($|\s+|-)/m, 1]

  return {} if options_options.nil?

  puts "=> options after get_options_hash => #{options_options}".magenta

  begin
    eval(options_options)
  rescue StandardError
    {}
  end
end

def get_option_modules(modules)
  return '' if modules.nil? || modules.empty?

  extracted_modules = modules[/-m\s*([\[{"].+?(["}\]\s-]$?))($|\s+|-)/m, 1]

  return '' if extracted_modules.nil?

  extracted_modules = extracted_modules.strip.gsub(/\s+/, ' ')

  puts "=> modules after get_option_modules => #{extracted_modules}".magenta

  begin
    eval(extracted_modules)
  rescue StandardError
    ''
  end
end

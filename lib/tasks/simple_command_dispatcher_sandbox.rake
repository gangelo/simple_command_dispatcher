require 'rake'
# Tasks to play with certain klass_transform module members


desc 'Test to_class_string'
task :to_class_string do
   require "colorize"
   require "simple_command_dispatcher"

   class Test
      prepend SimpleCommand::KlassTransform
   end
  
   STDOUT.puts "Testing SimpleCommand::KlassTransform#to_class_String...\n".cyan
   STDOUT.puts "Enter a blank line to exit.".cyan
    loop do 
      STDOUT.puts "\nEnter \"-class [class], -options [options]\" where class = String or Symbol and options = Hash (e.g. -class my_class || :my_class -options { class_camelize: true })\n".cyan

      input = STDIN.gets.chomp
      break if input.empty?

      klass = get_option_class(input)
      if klass.nil? || klass.empty?
         print "=> Error: Class not a String or Symbol\n".red
         next
      elsif !klass.is_a?(String) && ! klass.is_a?(Symbol)
         print "=> Error: Class not a String or Symbol\n".red
         next
      end

      options_hash = get_options_hash(input)
      options_hash = { class_camelize: true }.merge(options_hash || {})

      puts "Calling to_class_string with the following parameters: class: #{klass.class}, options: #{options_hash.class}".cyan


      klass = "\"#{klass}\"" if klass.is_a?(String)
      print "Success: => #to_class_String(#{klass}, #{options_hash}) => \"#{Test.new.to_class_string(klass, options_hash)}\"\n".green
    end

    print
    print 'Done'.yellow
    print
end


desc 'Test to_modules_string'
task :to_modules_string do
   require "colorize"
   require "simple_command_dispatcher"

   class Test
      prepend SimpleCommand::KlassTransform
   end
  
   STDOUT.puts "Testing SimpleCommand::KlassTransform#to_modules_string...\n".cyan
   STDOUT.puts "Enter a blank line to exit.".cyan
    loop do 
      STDOUT.puts "\nEnter \"-m [modules], -o [options]\" where modules = Hash, Array or String and options = Hash".cyan
      STDOUT.puts "\n\tExample: -m \"Module1::Module2::Module3\" -o { modules_camelize: true }\n".cyan
      STDOUT.puts "\n\tExample: -m [:module1, :module2, :module3] -o { modules_camelize: true }\n".cyan
      STDOUT.puts "\n\tExample: -m { api: :api, app: :crazy_buttons, version: :v1] -o { modules_camelize: true }\n".cyan

      print "=> "

      input = STDIN.gets.chomp
      break if input.empty?

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
      options_hash = { class_camelize: true }.merge(options_hash || {})

      puts "\nCalling to_modules_string with the following parameters: modules: #{modules}, type: #{modules.class}, options: #{options_hash}, type: #{options_hash.class}...".cyan


      #modules = "\"#{modules}\"" if modules.is_a?(String)
      puts "\nSuccess: => #to_modules_string(#{modules}, #{options_hash}) => #{Test.new.to_modules_string(modules, options_hash)}\n".green
    end

    print
    print 'Done'.yellow
    print

end


desc 'Test to_constantized_class_string'
task :to_constantized_class_string do
  puts "to_constantized_class_string"
end

def get_option_class(options)
   if options.nil? || options.empty?
      return ""
   end
   options_options = options[/(-class\s*)(.*?)\s.*/m,2]

   return "" if options_options.nil?

   klass = options_options.strip.gsub(/\s+/, " ")

   klass
end

def get_options_hash(options)
   if options.nil? || options.empty?
      return ""
   end
   options_options = options[/(-options|-o)(.*?)}/]

   return "" if options_options.nil?

   options_options = options_options[/{(.*?)}/]

   begin
      eval(options_options)
   rescue
      ""
   end
end

def get_option_modules(modules)
   if modules.nil? || modules.empty?
      return ""
   end

   extracted_modules = modules[/-m\s*((\[|{|").*?(\]|}|")).*/m,1]

   return "" if extracted_modules.nil?

   extracted_modules = extracted_modules.strip.gsub(/\s+/, " ")

   p extracted_modules

   begin
      eval(extracted_modules)
   rescue
      ""
   end
end




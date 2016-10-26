module SimpleCommand
   module KlassTransform

      public 

         # Returns a constantized class
         def to_constantized_class(klass, klass_modules = [], options = {})
            to_constantized_class_string(klass, klass_modules, options).constantize
         end

         # Returns a constantized class as a string
         def to_constantized_class_string(klass, klass_modules = [], options = {})
            options = ensure_options(options)
            klass_modules = to_modules_string(klass_modules, options)
            klass_string = to_class_string(klass, options)
            "#{klass_modules}#{klass_string}"
         end

         # Returns the modules as a string (e.g. "Api::Auth::V1::")
         def to_modules_string(klass_modules = [], options = {})
            klass_modules = validate_klass_modules(klass_modules)

            options = ensure_options(options)

            klass_modules_string = ''
            if !klass_modules.empty?
               case klass_modules
                  when String
                     klass_modules_string = klass_modules
                  when Array
                     klass_modules_string = "#{klass_modules.join('::')}"
                  when Hash
                     klass_modules_string = ''
                     klass_modules.to_a.each_with_index.map { | value, index | 
                        klass_modules_string = index == 0 ? value[1].to_s : "#{klass_modules_string}::#{value[1]}"
                     }
                  else
                     raise ArgumentError.new('Class modules is not a String, Hash or Array.')
               end

               klass_modules_string = klass_modules_string.split('::').map(&:titleize).join('::') if options[:module_titleize]
               klass_modules_string = klass_modules_string.trim_all
               klass_modules_string = "#{klass_modules_string}::" unless klass_modules_string.empty?
            end
            # p klass_modules_string
            klass_modules_string
         end

         # Returns the class as a string after transformations.
         def to_class_string(klass, options = {})
            klass = klass.to_s unless klass.instance_of? String
            if options[:titleize_command]
               klass = klass.titleize
            end
            klass
         end


      private

         def ensure_options(options)
            options = {} unless options.instance_of? Hash
            options = { class_titleize: false, module_titleize: false }.merge(options)
            options
         end

         def validate_klass_modules(klass_modules)
            return {} if klass_modules.nil? || (klass_modules.respond_to?(:empty?) && klass_modules.empty?)

            if !klass_modules.instance_of?(String) && !klass_modules.instance_of?(Hash) && !klass_modules.instance_of?(Array)
               raise ArgumentError.new('Class modules is not a String, Hash or Array.')
            end

            klass_modules
         end
   end
end

module SimpleCommand

   # Handles class and module transformations.
   module KlassTransform
         # Returns a constantized class (as a Class constant), given the klass and klass_modules.
         #
         # @param klass [Symbol or String] the class name.
         # @param klass_modules [Hash, Array or String] the modules klass belongs to.
         # @param options [Hash] the options that determine how klass_modules is transformed.
         # @option options [Boolean] :class_titleize (false) Determines whether or not klass should be titleized.
         # @option options [Boolean] :module_titleize (false) Determines whether or not klass_modules should be titleized.
         #
         # @return [Class] the class constant. Can be used to call ClassConstant.constantize.
         #
         # @raise [NameError] if the constantized class string cannot be constantized; that is, if it is not
         #   a valid class constant.
         #
         # @example
         #
         #   to_constantized_class("Authenticate", "Api") # => Api::Authenticate
         #   to_constantized_class(:Authenticate, [:Api, :AppName, :V1]) # => Api::AppName::V1::Authenticate
         #   to_constantized_class(:Authenticate, { :api :Api, app_name: :AppName, api_version: :V2 }) # => Api::AppName::V2::Authenticate
         #   to_constantized_class("authenticate", { :api :api, app_name: :app_name, api_version: :v1 }, { class_titleize: true, module_titleize: true }) # => Api::AppName::V1::Authenticate
         #
         def to_constantized_class(klass, klass_modules = [], options = {})
            constantized_class_string = to_constantized_class_string(klass, klass_modules, options)

            begin
               constantized_class_string.constantize
            rescue
                raise NameError.new("\"#{constantized_class_string}\" is not a valid class constant.")
            end
         end

         # Returns a fully-qualified constantized class (as a string), given the klass and klass_modules.
         #
         # @param [Symbol or String] klass the class name.
         # @param [Hash, Array or String] klass_modules the modules klass belongs to.
         # @param [Hash] options the options that determine how klass_modules is transformed.
         # @option options [Boolean] :class_titleize (false) Determines whether or not klass should be titleized.
         # @option options [Boolean] :module_titleize (false) Determines whether or not klass_modules should be titleized.
         #
         # @return [String] the fully qualified class, which includes module(s) and class name.
         #
         # @example
         #
         #   to_constantized_class_string("Authenticate", "Api") # => "Api::Authenticate"
         #   to_constantized_class_string(:Authenticate, [:Api, :AppName, :V1]) # => "Api::AppName::V1::Authenticate"
         #   to_constantized_class_string(:Authenticate, { :api :Api, app_name: :AppName, api_version: :V2 }) # => "Api::AppName::V2::Authenticate"
         #   to_constantized_class_string("authenticate", { :api :api, app_name: :app_name, api_version: :v1 }, { class_titleize: true, module_titleize: true }) # => "Api::AppName::V1::Authenticate"
         #
         def to_constantized_class_string(klass, klass_modules = [], options = {})
            options = ensure_options(options)
            klass_modules = to_modules_string(klass_modules, options)
            klass_string = to_class_string(klass, options)
            "#{klass_modules}#{klass_string}"
         end

         # Returns a string of modules that can be subsequently prepended to a class, to create a constantized class.
         #
         # @param [Hash, Array or String] klass_modules the modules a class belongs to.
         # @param [Hash] options the options that determine how klass_modules is transformed.
         # @option options [Boolean] :module_titleize (false) Determines whether or not klass_modules should be titleized.
         #
         # @return [String] a string of modules that can be subsequently prepended to a class, to create a constantized class.
         #
         # @raise [ArgumentError] if the klass_modules is not of type String, Hash or Array.
         #
         # @example
         #
         #   to_modules_string("Api") # => "Api::"
         #   to_modules_string([:Api, :AppName, :V1]) # => "Api::AppName::V1::"
         #   to_modules_string({ :api :Api, app_name: :AppName, api_version: :V1 }) # => "Api::AppName::V1::"
         #   to_modules_string({ :api :api, app_name: :app_name, api_version: :v1 }, { module_titleize: true }) # => "Api::AppName::V1::"
         #
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
               klass_modules_string = camelize(klass_modules_string) if options[:module_camelize]
               klass_modules_string = klass_modules_string.trim_all
               klass_modules_string = "#{klass_modules_string}::" unless klass_modules_string.empty?
            end

            klass_modules_string
         end

         # Returns the klass as a string after transformations have been applied.
         #
         # @param [Symbol or String] klass the class name to be transformed.
         # @param [Hash] options the options that determine how klass will be transformed.
         # @option options [Boolean] :class_titleize (false) Determines whether or not klass should be titleized.
         #
         # @return [String] the transformed class as a string.
         #
         # @example
         #
         #   to_class_string("MyClass") # => "MyClass"
         #   to_class_string("myClass", { class_titleize: true }) # => "MyClass"
         #   to_class_string(:MyClass) # => "MyClass"
         #   to_class_string(:myClass, { class_titleize: true }) # => "MyClass"
         #
         def to_class_string(klass, options = {})
            klass = validate_klass(klass, options)
            if options[:class_titleize]
               klass = klass.titleize
            end
            if options[:class_camelize]
               klass = camelize(klass)
            end
            klass
         end

         # Transforms a route into a module string
         #
         # @example
         #
         #   module_to_route("/api/app/auth/v1") # => "Api::App::Auth::V1"
         #   module_to_route("/api/app_name/auth/v1") # => "Api::AppName::Auth::V1"
         #
         def camelize(token)
            if !token.instance_of? String
               raise ArgumentError.new('Token is not a String')
            end
            token = token.titlecase.camelize.sub(/^[:]*/,"").trim_all unless token.empty?
         end

         private

         # @!visibility public
         #
         # Ensures options are initialized and valid before accessing them.
         #
         # @param [Hash] options the options that determine how processing and transformations will be handled.
         # @option options [Boolean] :camelize (false) determines whether or not both class and module names should be camelized.
         # @option options [Boolean] :titleize (false) determines whether or not both class and module names should be titleized.
         # @option options [Boolean] :class_titleize (false) determines whether or not class names should be titleized.
         # @option options [Boolean] :module_titleize (false) determines whether or not module names should be titleized.
         # @option options [Boolean] :class_camelized (false) determines whether or not class names should be camelized.
         # @option options [Boolean] :module_camelized (false) determines whether or not module names should be camelized.
         #
         # @return [Hash] the initialized, validated options.
         #
         def ensure_options(options)
            options = {} unless options.instance_of? Hash
            options = { camelize: false, titleize: false, class_titleize: false, module_titleize: false, class_camelize: false, module_camelize: false}.merge(options)

            if options[:camelize]
               options[:class_camelize] = options[:module_camelize] = true
            end

            if options[:titleize]
               options[:class_titleize] = options[:module_titleize] = true
            end

            options
         end

         # @!visibility public
         #
         # Validates klass and returns klass as a string after all blanks have been removed using klass.gsub(/\s+/, "").
         #
         # @param [Symbol or String] klass the class name to be validated. klass cannot be empty?
         #
         # @return [String] the validated class as a string with blanks removed.
         #
         # @raise [ArgumentError] if the klass is empty? or not of type String or Symbol.
         #
         # @example
         #
         #   validate_klass(" My Class ") # => "MyClass"
         #   validate_klass(:MyClass) # => "MyClass"
         #
         def validate_klass(klass, options)
            if !(klass.is_a?(Symbol) || klass.is_a?(String))
               raise ArgumentError.new('Class is not a String or Symbol. Class must equal the name of the SimpleCommand to call in the form of a String or Symbol.')
            end

            klass = klass.to_s.strip

            if klass.empty?
               raise ArgumentError.new('Class is empty?')
            end

            klass
         end

         # @!visibility public
         #
         # Validates and returns klass_modules.
         #
         # @param [Symbol, Array or String] klass_modules the module(s) to be validated.
         #
         # @return [Symbol, Array or String] the validated module(s).
         #
         # @raise [ArgumentError] if the klass_modules is not of type String, Hash or Array.
         #
         # @example
         #
         #   validate_modules(" Module ") # => " Module "
         #   validate_modules(:Module) # => "Module"
         #   validate_module("ModuleA::ModuleB") # => "ModuleA::ModuleB"
         #
         # @private
         def validate_klass_modules(klass_modules)
            return {} if klass_modules.nil? || (klass_modules.respond_to?(:empty?) && klass_modules.empty?)

            if !klass_modules.instance_of?(String) && !klass_modules.instance_of?(Hash) && !klass_modules.instance_of?(Array)
               raise ArgumentError.new('Class modules is not a String, Hash or Array.')
            end

            klass_modules
         end
      #end
   end
end
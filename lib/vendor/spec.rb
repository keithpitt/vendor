module Vendor

 
  class Spec

    #
    # Load the specified Vendor specification file. A vendor specification file is
    # simply the Ruby code to generate a specificatio
    # 
    # @note the following method performs an `eval` with the source found within
    #   the specificed file. This could contain any action native to ruby which
    #   may lead to unintended or malicous effects.
    # 
    # @return [Vendor::Spec] the Vendor::Spec parse and evaluated fom the specified
    #   file.
    # 
    def self.load(file)
      # Before evaling we need to chdir into the location of the vendorspec. This is
      # so if the vendorfile does any system calls, they're expecting to be in the right
      # right location.
      before = Dir.pwd
      Dir.chdir File.dirname(file)
      spec = eval File.read(file), nil, file
      Dir.chdir before
      spec
    end


    
    #
    # Create a new specification
    # 
    #     Vendor::Spec.new do |s|
    #
    #       s.name           "DKBenchmark"
    #       s.version        "0.1"
    #
    #       s.authors        "keithpitt"
    #       s.email          "me@keithpitt.com"
    #       s.description    "Easy benchmarking in Objective-C using blocks"
    #       s.files          [ "DKBenchmark.h", "DKBenchmark.m" ]
    # 
    #     end 
    # 
    # @param [Block] block the specified block given allows for additional
    #   configuration of the Specificattion.
    #
    def initialize(&block)
      @attributes = {}
      @build_settings = []
      @frameworks = []
      @dependencies = []
      yield(self) if block_given?
    end

    # @return [Hash] a hash that contains the attributes defined for the 
    #   specification. These attributes should be set through the dynamic methods
    #   defined for each attribute.
    attr_reader :attributes

    #
    # @param [Block] block define a validation for the specified attribute to
    #   ensure that it meets the criteria required for it to be saved properly
    #   to the vendor specification
    # 
    def self.on_validate(&block)
      (@validations ||= []) << block
    end
  
    # 
    # Perform a validation on an instance of a Vendor::Spec. This is intended
    # to be called from the instance itself through the #validate! method.
    # 
    # @see Spec#validate!
    # 
    def self.validate(spec_instance)
      @validations.each do |validation|
        validation.call(spec_instance)
      end
    end
    
    #
    # Validate the instance. If the vendor specification is considered invalid
    # an exception will be raised that describes the nature of the validation.
    # 
    # @return [void]
    def validate!
      self.class.validate(self)
    end
  
    #
    # Define various attributes of a vendor specification. This method is to be
    # used internally within the class as a DSL to define various methods and
    # validations.
    # 
    # @param [String,Symbol] name the name of the attribute that will have various
    #   getters, setters, and validators generated.
    # 
    # @param [Hash,Symbol] options additional parameters that allow additional
    #   configuration of the properties
    # 
    def self.attribute(name,options = {})

      options = { options => nil } unless options.is_a? Hash

      # Define a traditional setter for the attribute
      
      define_method "#{name}=" do |value|
        @attributes[name] = value
      end

      # Define a getter or a setter (depending if the method has been called with
      # arguments or not)

      define_method "#{name}" do |*args|

        if args.length == 1
          @attributes[name] = args.first
        else
          @attributes[name]
        end
        
      end

      # Define validations for the properties which are marked as required

      if options.key?(:required)

        on_validate do |instance|
          value = instance.send(name)
          
          if value.respond_to?(:empty?) ? value.empty? : !value
            raise StandardError.new("Specification is missing the `#{name}` option")
          end
        end
        
      end
      
    end

    
    # @attribute 
    # The name of the vendor specification
    attribute :name, :required
    
    # @attribute
    # The verison of this release
    attribute :version, :required

    # @attribute
    # The files to include in this release of the vendor specification
    attribute :files, :required
    
    # @attribute
    # A description to give users context about this particular vendor specification
    attribute :description

    # @attribute
    # The authors responsible for this project
    attribute :authors

    # @attribute
    # The email that a user could use to contact with support issues
    attribute :email, :required

    # @attribute
    # The homepage where a user could find more information about the project
    attribute :homepage

    # @attribute
    # The location where a user could find the original source code
    attribute :source

    # @attribute
    # The location where a user could find the documentation about the vendor
    # specification.
    attribute :docs
 
    
    BUILD_SETTING_NAMES = {
      :other_linker_flags => "OTHER_LDFLAGS"
    }

    # @see build_setting
    attr_reader :build_settings
   
    #
    # Add additional build configuration information required for the specification
    # to build and run succesfully on the installed system.
    # 
    # @note currently all build settings that are added here will be uniquely 
    #   appended to the existing build settings of the target configuration that 
    # 
    # @param [String,Symbol] setting the target configuration setting name
    # 
    # @note The settings can be specified as their environment variable string 
    #   (e.g. "GCC_PRECOMPILE_PREFIX_HEADER"). Some of the common properties can 
    #   be referenced by symbolic names (e.g. :precompile_prefix_headers). The
    #   current list of supported symbolic names is available in the Xcoder gem.
    # 
    # @see https://github.com/rayh/xcoder/blob/master/lib/xcode/configuration.rb
    # 
    # @example Specifying build configuration
    # 
    #     Vendor::Spec.new do |spec|
    #       spec.build_setting 'GCC_PRECOMPILE_PREFIX_HEADER', 'YES'
    #       spec.build_settings :user_header_search_paths, '/custom/header/search/path'
    #     end
    # 
    # @param [String,Symbol,Array] value will be appended to the existing values
    #   for the given configuration.
    # 
    # @return [void]
    # 
    def build_setting(setting, value)
      # If you pass in a symbol, it'll try and map it.
      if setting.kind_of?(Symbol)
        symbol = setting
        setting = BUILD_SETTING_NAMES[symbol]
        raise StandardError.new("No mapping for '#{symbol}' in #{BUILD_SETTING_NAMES.inspect}") unless setting
      end

      # YES/NO Mappings
      if value === true
      value = "YES"
      elsif value === false
        value = "NO"
      end

      
      @build_settings << [ setting, value ]
    end
    
    
    # @see #framework
    attr_reader :frameworks
  
    #
    # Load any additional system frameworks or system libraries required by the project.
    # 
    # @param [String] name of the System framework
    # 
    # @note Frameworks can be specifiedy with or without the framework file
    #   extension. Also it is assumed that all frameworks specified are system
    #   frameworks and can be found alongside the other system frameworks.
    # 
    # @example Specifying framework with or without the framework extension
    # 
    #     Vendor::Spec.new do |spec|
    #       spec.framework 'CoreGraphics.framework'
    #       spec.framework 'UIKit'
    #     end
    # 
    # @note Dynamic system libraries must be specified with the `dylib` file
    #   extension. It is assumed that the all system libraries can be found
    #   in the `/user/lib` folder.
    # 
    # @example Specifying dynamic library
    # 
    #     Vendor::Spec.new do |spec|
    #       spec.framework 'libz.dylib'
    #     end
    # 
    # @return [void] 
    # 
    def framework(name)
      @frameworks << name
    end

    # @see #dependency
    attr_reader :dependencies

    #
    # Specify any additional dependencies for the vendor specification.
    # 
    # @param [String] name is the name of the required library
    # @param [String] version the required version by this specification
    # 
    # @return [void]
    # 
    def dependency(name, version = nil)
      @dependencies << [ name, version ]
    end
    
    #
    # @return a JSON representation of the vendor specification which will be
    #   packaged and shipped with the other files.
    # 
    def to_json
      [ @attributes.keys, :dependencies, :frameworks, :build_settings ].flatten.inject({}) do |hash, attr|
        val = self.send(attr)
        hash[attr] = val unless val.nil?
        hash
      end.to_json
    end
    
  end

end

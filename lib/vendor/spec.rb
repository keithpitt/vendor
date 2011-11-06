module Vendor

  class Spec

    ATTRIBUTES = [ :name, :version, :email, :files, :homepage,
                   :description, :authors, :source, :docs ]

    attr_reader :dependencies
    attr_reader :frameworks
    attr_reader :build_settings

    BUILD_SETTING_NAMES = {
      :other_linker_flags => "OTHER_LDFLAGS"
    }

    ATTRIBUTES.each do |attr|
      class_eval %{
        def #{attr}(*args)
          if args.length == 1
            self.#{attr} = args.first
          else
            @attributes[:#{attr}]
          end
        end

        def #{attr}=(value)
          @attributes[:#{attr}] = value
        end
      }
    end

    def self.load(file)
      eval File.read(file), nil, file
    end

    def initialize(&block)
      @attributes = {}
      yield(self) if block_given?
    end

    def build_setting(setting, value)
      @build_settings ||= []

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

    def framework(name)
      @frameworks ||= []
      @frameworks << name
    end

    def dependency(name, version = nil)
      @dependencies ||= []
      @dependencies << [ name, version ]
    end

    def validate!
      [ :name, :version, :email, :files ].each do |key|
        value = self.send(key)

        if value.respond_to?(:empty?) ? value.empty? : !value
          raise StandardError.new("Specification is missing the `#{key}` option")
        end
      end
    end

    def to_json
      [ ATTRIBUTES, :dependencies, :frameworks, :build_settings ].flatten.inject({}) do |hash, attr|
        val = self.send(attr)
        hash[attr] = val unless val.nil?
        hash
      end.to_json
    end

  end

end

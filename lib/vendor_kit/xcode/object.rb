module VendorKit::XCode

  class Object

    def self.reference(name)
      attribute = attribute_name(name)
      define_method name do
        value = @attributes[attribute]
        if value.kind_of?(Array)
          value.map { |id| @project.find_object(id) }
        else
          @project.find_object(value)
        end
      end
    end

    # References are stored in camel case in the project file
    def self.attribute_name(name)
      camelized = name.to_s.gsub(/[^\w]/, '').gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      camelized[0].chr.downcase + camelized[1..-1]
    end

    def initialize(options)
      @id = options[:id]
      @project = options[:project]
      @attributes = options[:attributes]
    end

    def inspect
      properties = { "id" => @id }.merge(@attributes)

      # The class name contains the ISA (the type of the object)
      properties.delete("isa")

      # Always show the ID first
      keys = properties.keys
      keys.delete("id")
      keys.unshift("id")

      "#<#{self.class.name} #{keys.map{ |key| "#{underscore(key)}: #{properties[key].inspect}" }.join(', ')}>"
    end

    def method_missing(v, *args)
      setting = v.match(/\=$/)
      name = self.class.attribute_name(v)

      if @attributes.has_key?(name)
        if setting
          write_attribute(name, args.first)
        else
          read_attribute(name)
        end
      else
        super
      end
    end

    def write_attribute(name, value)
      @attributes[name] = value
    end

    def read_attribute(name)
      @attributes[name]
    end

    private

      # I miss active support...
      def underscore(string)
        string.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

  end

end

module VendorKit::XCode

  class Object

    def self.reference(name)
      attribute = attribute_name(name)
      define_method name do
        @project.find_object(@attributes[attribute])
      end
    end

    # References are stored in camel case in the project file
    def self.attribute_name(name)
      camelized = name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      camelized[0].chr.downcase + camelized[1..-1]
    end

    def initialize(options)
      @id = options[:id]
      @project = options[:project]
      @attributes = options[:attributes]
    end

    def inspect
      properties = { :id => @id }.merge(@attributes)
      "#<#{self.class.name} #{properties.map{ |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
    end

  end

end

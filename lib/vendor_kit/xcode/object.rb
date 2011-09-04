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
      camelized = name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      camelized[0].chr.downcase + camelized[1..-1]
    end

    def initialize(options)
      @id = options[:id]
      @project = options[:project]
      @attributes = options[:attributes]
    end

    def inspect
      properties = { "id" => @id }.merge(@attributes)
      keys = properties.keys.map(&:to_s).sort
      "#<#{self.class.name} #{keys.map{ |key| "#{key}: #{properties[key].inspect}" }.join(', ')}>"
    end

  end

end

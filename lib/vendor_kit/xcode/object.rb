module VendorKit::XCode

  class Object

    def self.reference(name)
      define_method name do
        @project.find_object(@attributes[name.to_s])
      end
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

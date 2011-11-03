module Vendor

  class Spec

    ATTRIBUTES = [ :name, :version, :email, :files, :homepage,
                   :description, :dependencies, :authors, :source, :docs ]

    attr_accessor *ATTRIBUTES

    def self.load(file)
      eval File.read(file), nil, file
    end

    def initialize(&block)
      yield(self) if block_given?
    end

    def dependency(name, version)
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
      [ ATTRIBUTES, :dependencies ].flatten.inject({}) do |hash, attr|
        val = self.send(attr)
        hash[attr] = val unless val.nil?
        hash
      end.to_json
    end

  end

end

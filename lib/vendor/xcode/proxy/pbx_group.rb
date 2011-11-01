module Vendor::XCode::Proxy

  class PBXGroup < Vendor::XCode::Proxy::Base

    reference :children

    def name
      @attributes['name'] || @attributes['path']
    end

    def full_path
      parts = []
      current = self

      while current
        parts.push current.name
        current = current.parent
      end

      parts.reverse.compact.join("/")
    end

    def group?
      true
    end

    private

      def after_initialize
        children.each { |child| child.parent = self }
      end

  end

end

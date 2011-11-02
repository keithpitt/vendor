module Vendor

  module Template

    require 'erb'

    class Locals

      def initialize(options)
        # Create methods for each of the options
        (class << self; self; end).class_eval do
          options.each_pair do |key, value|
            define_method key.to_sym do
              value
            end
          end
        end
      end

      def get_binding
        return binding()
      end

    end

    class << self

      def copy(name, options = {})
        # Where should we write this file?
        file_name = options[:name] || name
        target = File.join(File.expand_path(Dir.pwd), file_name)

        # The template to load
        template = File.join(Vendor.root, "vendor", "templates", name)

        if File.exist?(target)
          Vendor.ui.error "#{name} already exists at #{target}"
        else
          Vendor.ui.info "Writing new #{name} to #{target}"

          contents = parse(File.read(template), options[:locals] || {})

          File.open(target, 'w') { |f| f.write(contents) }
        end
      end

      def parse(contents, locals)
        ERB.new(contents).result(Locals.new(locals).get_binding)
      end

    end

  end

end

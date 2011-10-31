module Vendor

  module Template

    def self.copy(name)
      target = File.join(File.expand_path(Dir.pwd), name)
      template = File.join(Vendor.root, "vendor", "templates", name)

      if File.exist?(target)
        Vendor.ui.error "#{name} already exists at #{target}"
      else
        FileUtils.copy template, target

        Vendor.ui.info "Writing new #{name} to #{target}"
      end
    end

  end

end

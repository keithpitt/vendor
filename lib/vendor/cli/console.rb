module Vendor

  module CLI

    module Console

      RESOURCE_PATH = File.join(Vendor.root, "..", "spec", "support", "resources")
      PROJECT_RESOURCE_PATH = File.join(RESOURCE_PATH, "projects")

      # This reload method kinda works. It works if you change/add methods, but if you
      # remove methods from a class, they still seem to hang around. I believe there is
      # a fair amount of magic in rails that lets you call a reload!, but for the save
      # of Vendor development, this will suffice.
      def self.reload!
        begin
          old_verbose, $VERBOSE = $VERBOSE, nil
          $".grep(/\/lib\/vendor/).each {|e| $".delete(e) && require(e) }
        ensure
          $VERBOSE = old_verbose
        end
        "Reloaded!"
      end

      def self.example_project!(name)
        Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "#{name}/#{name}.xcodeproj"))
      end

    end

  end

end

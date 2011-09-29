module Vendor

  module CLI

    class App < Thor

      class Library < Thor

        desc "library build VENDORSPEC_FILE", "Build a vendor package from a vendorspec file"
        def build(file)
          builder = Vendor::VendorSpec::Builder.new(File.expand_path(file))
          if builder.build
            puts "Successfully built Vendor".green
            puts "Name: #{builder.name}"
            puts "Version: #{builder.version}"
            puts "File: #{builder.filename}"
          end
        end

        desc "library publish VENDOR_FILE", "Publish a vendor package to vendorforge.org"
        def publish(file)
          begin
            Vendor::CLI::Auth.with_api_key do |api_key|
              url = Vendor::API.publish :file => File.expand_path(file), :api_key => api_key
              puts "Successfully published to #{url}".green
            end
          rescue Vendor::API::Error => e
            puts "Error: #{e.message}".red
            exit 1
          end
        end

        # This is a hack so Thor doesn't output 2 help commands...
        def self.printable_tasks(all = true, subcommand = false)
          super.delete_if { |x| x[0].match(/vendor help/) }
        end

      end

      register Library, 'library', 'library <command>', 'Commands that will help you create and publish libraries', :hide => true

      desc "install", "Install the libraries defined in your Vendorfile to the current project"
      def install
        vendorfile = File.expand_path("Vendorfile")

        unless File.exist?(vendorfile)
          puts "Could not find Vendorfile".red
          exit 1
        end

        download_path = File.expand_path("~/.vendor/libraries/")

        loader = Vendor::VendorFile::Loader.new
        loader.load vendorfile
        loader.download download_path
        loader.install "Project"
      end

      desc "auth", "Login to your vendorforge.org account"
      def auth
        begin
          Vendor::CLI::Auth.with_api_key do |api_key|
            puts "Successfully authenticated".green
          end
        rescue Vendor::API::Error => e
          puts "Error: #{e.message}".red
        end
      end

      desc "console", "Load an interactive shell with the Vendor classes loaded"
      def console
        # Need to clear the arguments otherwise they are passed through to RIPL
        ARGV.clear
        Ripl.start :binding => Vendor::CLI::Console.instance_eval{ binding }
      end

      # Exit with 1 if thor encounters an error (such as command missing)
      def self.exit_on_failure?
        true
      end

    end

  end

end

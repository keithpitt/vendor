module Vendor

  module CLI

    class App < Thor

      class Library < Thor

        desc "library init", "Generate a simple vendorspec, placed in the current directory"
        def init
          # Use the current folder name as the name of the vendorspec
          name = File.basename(Dir.pwd)

          # Figure out who should be the author
          username = `git config --get github.user` ||
                     `git config --get github.user` ||
                     `whoami`
          email    = `git config --get user.email` ||
                     "#{username}@example.com"

          Vendor::Template.copy "vendorspec", :name => "#{name}.vendorspec",
                                              :locals => { :name => name,
                                                           :username => username.chomp,
                                                           :email => email.chomp }
        end

        desc "library build VENDORSPEC_FILE", "Build a vendor package from a vendorspec file"
        def build(file)
          builder = Vendor::VendorSpec::Builder.new(File.expand_path(file))
          if builder.build
            Vendor.ui.success "Successfully built library"
            Vendor.ui.info "Name: #{builder.name}"
            Vendor.ui.info "Version: #{builder.version}"
            Vendor.ui.info "File: #{builder.filename}"
          end
        end

        desc "library push VENDOR_FILE", "Push a vendor package to vendorforge.org"
        def push(file)
          begin
            Vendor::CLI::Auth.with_api_key do |api_key|
              url = Vendor::API.push :file => File.expand_path(file), :api_key => api_key
              Vendor.ui.success "Successfully pushed to #{Vendor::API.api_uri}#{url}"
            end
          rescue Vendor::API::Error => e
            Vendor.ui.error "Error: #{e.message}"
            exit 1
          end
        end

        # This is a hack so Thor doesn't output 2 help commands...
        def self.printable_tasks(all = true, subcommand = false)
          super.delete_if { |x| x[0].match(/vendor help/) }
        end

      end

      def initialize(*)
        super
        the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
        Vendor.ui = UI::Shell.new(the_shell)
        Vendor.ui.debug! if options["verbose"]
      end

      default_task :install
      class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
      class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"
      map "--version" => :version

      register Library, 'library', 'library <command>', 'Commands that will help you create and publish libraries', :hide => true

      desc "install", "Install the libraries defined in your Vendorfile to the current project"
      def install
        vendorfile = File.expand_path("Vendorfile")

        unless File.exist?(vendorfile)
          Vendor.ui.error "Could not find Vendorfile"
          exit 1
        end

        projects = Dir["*.xcodeproj"]

        if projects.length > 1
          Vendor.ui.error "Mutiple projects found #{projects.join(', ')}. I don't know how to deal with this yet."
          exit 1
        end

        project = Vendor::XCode::Project.new(projects.first)

        loader = Vendor::VendorFile::Loader.new
        loader.load vendorfile
        loader.install project

        if project.dirty?
          project.save
          Vendor.ui.success "Finished installing into #{project.name}"
        else
          Vendor.ui.info "No changes were made to #{project.name}"
        end
      end

      desc "init", "Generate a simple Vendorfile, placed in the current directory"
      def init
        Vendor::Template.copy "Vendorfile"
      end

      desc "auth", "Login to your vendorforge.org account"
      def auth
        begin
          Vendor::CLI::Auth.with_api_key do |api_key|
            Vendor.ui.success "Successfully authenticated"
          end
        rescue Vendor::API::Error => e
          Vendor.ui.error "Error: #{e.message}"
        end
      end

      desc "console", "Load an interactive shell with the Vendor classes loaded (used for development)"
      def console
        # Need to clear the arguments otherwise they are passed through to RIPL
        ARGV.clear
        Ripl.start :binding => Vendor::CLI::Console.instance_eval{ binding }
      end

      desc "version", "Output the current version of vendor", :hide => true
      def version
        Vendor.ui.info Vendor::VERSION
      end

      # Exit with 1 if thor encounters an error (such as command missing)
      def self.exit_on_failure?
        true
      end

    end

  end

end

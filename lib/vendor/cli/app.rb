require 'xcoder'

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

        desc "library push VENDOR_FILE", "Push a vendor package to vendorkit.com"
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

      class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
      class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"

      map "--version" => :version
      map "-v" => :version

      register Library, 'library', 'library <command>', 'Commands that will help you create and publish libraries', :hide => true

      desc "install", "Install the libraries defined in your Vendorfile to the current project"
      def install
        vendorfile = File.expand_path("Vendorfile")
        
        unless File.exist?(vendorfile)
          Vendor.ui.error "Could not find Vendorfile"
          exit 1
        end
        
        loader = Vendor::VendorFile::Loader.new
        loader.load vendorfile
        
        Dir["*.xcodeproj"].each do |project_path|
          
          Vendor.ui.info "Examining #{project_path}"
          
          project = Xcode.project project_path
          
          loader.libraries_to_install do |library,targets|
            
            library.download
            
            if targets == [:all]
              project_targets = project.targets
            else
              project_targets = targets.map {|name| project.target(name) }
            end
            
            if project_targets.empty?
              Vendor.ui.info "No targets have been specified in #{project.name}"
              return
            end
            
            FileUtils.mkdir_p "Vendor/#{library.name}"
            
            project.group("Vendor/#{library.name}") do
              library.files.each do |file| 
                Vendor.ui.info "* Installing file: #{file}"
                create_file 'name' => File.basename(file), 'path' => "Vendor/#{library.name}/#{File.basename(file)}"
                FileUtils.cp file, "Vendor/#{library.name}/#{File.basename(file)}"
              end
            end
            
            frameworks_added = library.frameworks.map do |framework_name|
              if framework_name =~ /^.+\.dylib$/
                Vendor.ui.info "* Installing System Library: #{framework_name}"
                project.frameworks_group.create_system_library(framework_name)
              else
                Vendor.ui.info "* Installing System Framework: #{framework_name}"
                project.frameworks_group.create_system_framework(framework_name)
              end
            end
            
            project_targets.each do |target|
              
              Vendor.ui.info "Target #{target.name} build phases"
              
              target.sources_build_phase do
                library.files.find_all {|file| File.extname(file) =~ /\.mm?$/ }.each do |file|
                  Vendor.ui.info "#{target.name} # adding build file: Vendor/#{library.name}/#{File.basename(file)}"
                  add_build_file project.file("Vendor/#{library.name}/#{File.basename(file)}")
                end
              end
              
              target.resources_build_phase do
                library.files.reject {|file| File.extname(file) =~ /\.(mm?|h)$/ }.each do |file|
                  Vendor.ui.info "#{target.name} # adding resources file: Vendor/#{library.name}/#{File.basename(file)}"
                  add_build_file project.file("Vendor/#{library.name}/#{File.basename(file)}")
                end
              end
              
              target.framework_build_phase do
                frameworks_added.each do |framework| 
                  Vendor.ui.info "#{target.name} # adding build framework: #{framework.name}"
                  add_build_file framework
                end
              end
              
            end
            
          end

          Vendor.ui.success "Finished installing into #{project.name}"
          
          project.save!
          
        end

      end

      desc "init", "Generate a simple Vendorfile, placed in the current directory"
      def init
        Vendor::Template.copy "Vendorfile"
      end

      desc "auth", "Login to your vendorkit.com account"
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
        Vendor.ui.info Vendor.version
      end

      # Exit with 1 if thor encounters an error (such as command missing)
      def self.exit_on_failure?
        true
      end

    end

  end

end

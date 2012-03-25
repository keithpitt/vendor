module Vendor
  module VendorSpec

    class Builder

      class NoFilesError < StandardError; end

      require 'fileutils'
      require 'tmpdir'
      require 'find'
      require 'zip/zipfilesystem'
      require 'json'

      attr_reader :name
      attr_reader :version
      attr_reader :filename
      attr_reader :vendor_spec

      def initialize(vendor_spec)
        @folder = File.expand_path(File.join(vendor_spec, '..'))
        @vendor_spec = Vendor::Spec.load vendor_spec

        @name = safe_filename(@vendor_spec.name)
        @version = safe_filename(@vendor_spec.version)
        @filename = "#{@name}-#{@version}.vendor"
      end

      def build
        tmpdir = Dir.mktmpdir(@filename)

        vendor_file = File.join(tmpdir, "vendor.json")
        data_dir = File.join(tmpdir, "data")
        data_files = copy_files(data_dir)

        open(vendor_file, 'w+') { |f| f << @vendor_spec.to_json }

        FileUtils.rm(@filename) if File.exist?(@filename)

        zip_file @filename, [ vendor_file, *data_files ], tmpdir

        true
      end

      private

        # Remove files that are within folders with a ".", such as ".bundle"
        # and ".frameworks" 
        def filter_files(files)
          Array(files).reject { |file| file =~ /\/?[^\/]+\.[^\/]+\// }
        end

        # Find all the files within the vendor spec to install
        def vendor_spec_files_to_install
          filter_files(@vendor_spec.files) + filter_files(@vendor_spec.resources)
        end

        def copy_files(data_dir)
          data_files = []

          raise NoFilesError.new("No file definition found for #{@name}") if @vendor_spec.files.nil?

          copy_files = vendor_spec_files_to_install

          raise NoFilesError.new("No files found for packaging") if copy_files.empty?

          copy_files.each do |file|
            dir = File.dirname(file)
            path = File.join(@folder, file)
            copy_to_dir = File.expand_path(File.join(data_dir, dir))
            copy_to_file = File.join(copy_to_dir, File.basename(file))

            Vendor.ui.debug "Creating dir #{copy_to_dir}"
            FileUtils.mkdir_p copy_to_dir

            Vendor.ui.debug "Copying #{path} to #{copy_to_file}"
            FileUtils.cp_r path, copy_to_file

            data_files << copy_to_file
          end

          data_files
        end

        def zip_file(filename, files, base_dir)
          Zip::ZipFile.open(filename, Zip::ZipFile::CREATE)do |zipfile|

            files.each do |file|
              path = file.gsub(base_dir, '').gsub(/^\//, '')
              zipfile.add path, file
            end

          end
        end

        def safe_filename(filename)
          filename.gsub(/[^a-zA-Z0-9\-\_\.]/, '')
        end

    end

  end
end

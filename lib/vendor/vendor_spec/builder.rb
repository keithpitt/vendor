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

        # Find all the files within the vendor spec to install
        def vendor_spec_files_to_install
          Array(@vendor_spec.files) + Array(@vendor_spec.resources)
        end

        def copy_files(data_dir)
          data_files = []

          raise NoFilesError.new("No file definition found for #{@name}") if @vendor_spec.files.nil?

          copy_files = vendor_spec_files_to_install

          raise NoFilesError.new("No files found for packaging") if copy_files.empty?

          FileUtils.mkdir_p data_dir unless File.exists? data_dir
          
          FileUtils.cp_r copy_files, data_dir

          Dir.glob(File.join([data_dir, "**/*"]))
        end

        def zip_file(filename, files, base_dir)
          Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zipfile|

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

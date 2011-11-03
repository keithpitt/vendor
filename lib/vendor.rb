require "vendor/version"

require "vendor/extensions/array"
require "vendor/extensions/hash"
require "vendor/extensions/fixnum"
require "vendor/extensions/string"

module Vendor

  autoload :UI,         'vendor/ui'
  autoload :Plist,      'vendor/plist'
  autoload :Config,     'vendor/config'
  autoload :API,        'vendor/api'
  autoload :Template,   'vendor/template'
  autoload :VendorFile, 'vendor/vendor_file'
  autoload :VendorSpec, 'vendor/vendor_spec'
  autoload :XCode,      'vendor/xcode'
  autoload :CLI,        'vendor/cli'
  autoload :Version,    'vendor/version'

  class << self

    attr_writer :ui

    def root
      File.join File.expand_path("../", __FILE__)
    end

    def ui
      @ui ||= UI.new
    end

    def library_path
      unless @library_path
        @library_path = File.expand_path("~/.vendor/libraries/")
        FileUtils.mkdir_p @library_path
      end
      @library_path
    end

  end

end

$:.push Vendor.root

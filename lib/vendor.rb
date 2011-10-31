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

  class << self

    attr_writer :ui

    def root
      File.join File.expand_path("../", __FILE__)
    end

    def ui
      @ui ||= UI.new
    end

  end

end

$:.push Vendor.root

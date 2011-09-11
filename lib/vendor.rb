$:.push File.expand_path("../", __FILE__)

require "vendor/version"
require "vendor/plist"
require "vendor/config"
require "vendor/api"

require "vendor/vendor_spec/builder"
require "vendor/vendor_spec/dsl"
require "vendor/vendor_spec/loader"

require "vendor/extensions/array"
require "vendor/extensions/hash"
require "vendor/extensions/fixnum"
require "vendor/extensions/string"

require "vendor/xcode/object"
require "vendor/xcode/project"

require "vendor/xcode/objects/pbx_project"
require "vendor/xcode/objects/pbx_file_reference"
require "vendor/xcode/objects/pbx_group"
require "vendor/xcode/objects/pbx_sources_build_phase"
require "vendor/xcode/objects/pbx_build_file"
require "vendor/xcode/objects/pbx_frameworks_build_phase"
require "vendor/xcode/objects/pbx_resources_build_phase"
require "vendor/xcode/objects/pbx_native_target"
require "vendor/xcode/objects/pbx_container_item_proxy"
require "vendor/xcode/objects/pbx_target_dependency"
require "vendor/xcode/objects/pbx_variant_group"
require "vendor/xcode/objects/pbx_shell_script_build_phase"
require "vendor/xcode/objects/xc_build_configuration"
require "vendor/xcode/objects/xc_configuration_list"

$:.push File.expand_path("../", __FILE__)

require "vendor_kit/version"
require "vendor_kit/plist"

require "vendor_kit/extensions/array"
require "vendor_kit/extensions/hash"
require "vendor_kit/extensions/fixnum"
require "vendor_kit/extensions/string"

require "vendor_kit/xcode/project"
require "vendor_kit/xcode/object"

require "vendor_kit/xcode/objects/pbx_project"
require "vendor_kit/xcode/objects/pbx_file_reference"
require "vendor_kit/xcode/objects/pbx_group"
require "vendor_kit/xcode/objects/pbx_sources_build_phase"
require "vendor_kit/xcode/objects/pbx_build_file"
require "vendor_kit/xcode/objects/pbx_frameworks_build_phase"
require "vendor_kit/xcode/objects/pbx_resources_build_phase"
require "vendor_kit/xcode/objects/pbx_native_target"
require "vendor_kit/xcode/objects/pbx_container_item_proxy"
require "vendor_kit/xcode/objects/pbx_target_dependency"
require "vendor_kit/xcode/objects/pbx_variant_group"
require "vendor_kit/xcode/objects/pbx_shell_script_build_phase"
require "vendor_kit/xcode/objects/xc_build_configuration"
require "vendor_kit/xcode/objects/xc_configuration_list"

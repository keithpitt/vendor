module Vendor

  module XCode

    module Proxy

      autoload :Base,                      "vendor/xcode/proxy/base"
      autoload :PBXProject,                "vendor/xcode/proxy/pbx_project"
      autoload :PBXFileReference,          "vendor/xcode/proxy/pbx_file_reference"
      autoload :PBXGroup,                  "vendor/xcode/proxy/pbx_group"
      autoload :PBXSourcesBuildPhase,      "vendor/xcode/proxy/pbx_sources_build_phase"
      autoload :PBXBuildFile,              "vendor/xcode/proxy/pbx_build_file"
      autoload :PBXFrameworksBuildPhase,   "vendor/xcode/proxy/pbx_frameworks_build_phase"
      autoload :PBXResourcesBuildPhase,    "vendor/xcode/proxy/pbx_resources_build_phase"
      autoload :PBXNativeTarget,           "vendor/xcode/proxy/pbx_native_target"
      autoload :PBXContainerItemProxy,     "vendor/xcode/proxy/pbx_container_item_proxy"
      autoload :PBXTargetDependency,       "vendor/xcode/proxy/pbx_target_dependency"
      autoload :PBXVariantGroup,           "vendor/xcode/proxy/pbx_variant_group"
      autoload :PBXShellScriptBuildPhase,  "vendor/xcode/proxy/pbx_shell_script_build_phase"
      autoload :XCBuildConfiguration,      "vendor/xcode/proxy/xc_build_configuration"
      autoload :XCConfigurationList,       "vendor/xcode/proxy/xc_configuration_list"
      autoload :XCVersionGroup,            "vendor/xcode/proxy/xc_version_group"

    end

  end

end

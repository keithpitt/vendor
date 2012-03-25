require 'xcoder'

module Vendor::XCode

  class Project

    attr_reader :project

    def initialize(project_folder)
      @project = Xcode.project project_folder
    end
    
    #
    # Install the library into the project for the selected targets.
    # 
    # @param [Library] library the instance that conveys the requirements to 
    #   install.
    # @param [Array<Symbols>] targets to install this library; The value :all 
    #   is a special target name that means all targets.
    #
    def install(library,targets)
      
      project_targets = project_targets_from_specified_targets(targets)
      
      if project_targets.empty?
        Vendor.ui.warn "The project '#{project.name}' does not have any matching targets"
        return
      end
      
      library_pathname = "Vendor/#{library.name}"

      
      files_added = create_library_folders_and_groups library_pathname, library.files
      
      resources_added = create_library_folders_and_groups library_pathname, library.resources
      
      frameworks_added = add_required_frameworks_to_project library.frameworks
  
     
      source_files = files_added.find_all {|file| File.extname(file.path.to_s) =~ /\.mm?$/ }

      framework_files = frameworks_added + files_added.find_all {|file| File.extname(file.path.to_s) =~ /\.a$/ }

      
      project_targets.each do |target|
        
        Vendor.ui.debug "\n= Configuring Build Target `#{target.name}`"
        
        add_source_files_to_sources_build_phase source_files, target.sources_build_phase, library.per_file_flag
        
        add_resource_files_to_resources_build_phase resources_added, target.resources_build_phase
        
        add_frameworks_to_frameworks_build_phase framework_files, target.framework_build_phase
        
        add_build_settings_to_target_configurations target, library.build_settings
        
      end
    
      project.save!
      
    end
    
    private
    
    
    #
    # Convert the target names to the actual target objects within the project
    # 
    # @param [Array<Symbols>] targets to install this library; The value :all 
    #   is a special target name that means all targets.
    #
    # @return [Array<Target>] the targets that match the specified target names.
    # 
    def project_targets_from_specified_targets(specified_targets)
      
      if specified_targets == [:all]
        
        project.targets
        
      else
        
        # Take each specified target names and compare those with the targets
        # specified within the project. Find all that match and return them,
        # ignoring aggregate targets that may match the name as they are
        # not capable of love that comes with bearing files.
        
        # @note project#target(name) seems like it would be a better choice,
        #    however, the Xcoder implementation raises an error when a target
        #    does not match the specified name.
        
        specified_targets.uniq.map do |name| 
          
          project.targets.reject {|target| target.isa == "PBXAggregateTarget" }.find_all {|target| target.name == name }
          
        end.flatten
      end
      
    end
    
    #
    # 
    # @param [String] pathname the path to create for the library
    # @param [Array<String>] files to copy into the project and create in the
    #   project.
    # @return [Array<FileReference>] an array of all the files that were added 
    #   to the project.
    #
    def create_library_folders_and_groups(pathname,files)
      
      # Create the physical path for the library
      
      FileUtils.mkdir_p pathname
      
      # Create the project's logical group for the library
      
      library_group = project.group pathname
      
      files.map do |file| 
        
        target_filepath = "#{pathname}/#{File.basename(file)}"
        
        Vendor.ui.debug "* [FILES] Installing File"
        Vendor.ui.debug "            from: #{file}"
        Vendor.ui.debug "              to: #{target_filepath}"
   
        # Copy the physical file to the library path
        
        FileUtils.cp file, target_filepath 
        
        # Copy the project's logical files
        
        library_group.create_file 'name' => File.basename(file), 'path' => target_filepath, 'sourceTree' => 'SOURCE_ROOT'
        
      end.compact
      
    end
    
    #
    # @param [Array<String>] frameworks to add to the frameworks section of the
    #   project.
    # @return [Array<FileReference>] an array of all the frameworks and system
    #   libraries that were added to the project.
    #
    def add_required_frameworks_to_project(frameworks)
      frameworks.map do |framework_name|
        if File.extname(framework_name) =~ /^\.dylib$/
          project.frameworks_group.create_system_library(framework_name)
        else
          project.frameworks_group.create_system_framework(framework_name)
        end
      end
    end
    
    
    def add_source_files_to_sources_build_phase files, sources_build_phase, per_file_flag
      
      unless sources_build_phase
        Vendor.ui.warn "! [SOURCE] No sources build phase exists for this target"
        return
      end
      
      files.each do |file|

        Vendor.ui.debug "* [SOURCE]     Adding : #{file.path}"
        
        if per_file_flag
          sources_build_phase.add_build_file file, { 'COMPILER_FLAGS' => per_file_flag }
        else
          sources_build_phase.add_build_file file
        end
      end
    end
    
    def add_resource_files_to_resources_build_phase files, resources_build_phase

      unless resources_build_phase
        Vendor.ui.warn "! [RESOURCES] No resources build phase exists for this target"
        return
      end
      
      files.each do |file|

        Vendor.ui.debug "* [RESOURCES]  Adding : #{file.path}"
        
        resources_build_phase.add_build_file file
      end
    end
    
    def add_frameworks_to_frameworks_build_phase frameworks, framework_build_phase

      unless framework_build_phase
        Vendor.ui.warn "! [FRAMEWORKS] No framework build phase exists for this target"
        return
      end
      
      frameworks.each do |framework|
        
        Vendor.ui.debug "* [FRAMEWORKS] Adding : #{framework.name}"
        
        framework_build_phase.add_build_file framework
      end
    end
    
    def add_build_settings_to_target_configurations target, build_settings
     
      target.configs.each do |config|
        
        build_settings.each do |name,value| 
          
          Vendor.ui.debug "* [CONFIG] Adding setting `#{name}` to value `#{value}`"
          
          config.append name, value

        end
      end
    end
    
  end

end

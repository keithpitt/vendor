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
        Vendor.ui.info "The project '#{project.name}' does not have any matching targets"
        return
      end
      
      library_pathname = "Vendor/#{library.name}"

      files_added = create_library_folders_and_groups library_pathname, library.files
      
      frameworks_added = add_required_frameworks_to_project library.frameworks
      
      project_targets.each do |target|
        
        add_source_files_to_sources_build_phase files_added, target.sources_build_phase
        
        add_resource_files_to_resources_build_phase files_added, target.resources_build_phase
        
        add_frameworks_to_frameworks_build_phase frameworks_added, target.framework_build_phase
        
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
        project_targets = project.targets
      else
        
        # Take each specified target names and compare those with the targets
        # specified within the project. Find all that match and return them,
        # ignoring aggregate targets that may match the name as they are
        # not capable of love that comes with bearing files.
        
        # @note project#target(name) seems like it would be a better choice,
        #    however, the Xcoder implementation raises an error when a target
        #    does not match the specified name.
        
        project_targets = specified_targets.each do |name| 
          
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
        Vendor.ui.info "* Installing file: #{file}"
        
        # Copy the physical file to the library path
        
        FileUtils.cp file, "#{pathname}/#{File.basename(file)}"
        
        # Copy the project's logical files
        
        library_group.create_file 'name' => File.basename(file), 'path' => "#{pathname}/#{File.basename(file)}"
        
      end
      
    end
    
    #
    # @param [Array<String>] frameworks to add to the frameworks section of the
    #   project.
    # @return [Array<FileReference>] an array of all the frameworks and system
    #   libraries that were added to the project.
    #
    def add_required_frameworks_to_project(frameworks)
      frameworks.map do |framework_name|
        if framework_name =~ /^.+\.dylib$/
          project.frameworks_group.create_system_library(framework_name)
        else
          project.frameworks_group.create_system_framework(framework_name)
        end
      end
    end
    
    
    def add_source_files_to_sources_build_phase files, sources_build_phase
      files.find_all {|file| File.extname(file.name) =~ /\.mm?$/ }.each do |file|
        sources_build_phase.add_build_file file
      end
    end
    
    def add_resource_files_to_resources_build_phase files, resources_build_phase
      files.reject {|file| File.extname(file.name) =~ /\.(mm?|h)$/ }.each do |file|
        resources_build_phase.add_build_file file
      end
    end
    
    def add_frameworks_to_frameworks_build_phase frameworks, framework_build_phase
      frameworks.each do |framework| 
        framework_build_phase.add_build_file framework
      end
    end
    
  end

end

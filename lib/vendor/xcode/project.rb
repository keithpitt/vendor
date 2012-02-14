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
        
        sources_build_phase = target.sources_build_phase
        
        library.files.find_all {|file| File.extname(file) =~ /\.mm?$/ }.each do |file|
          Vendor.ui.info "#{target.name} # adding build file: Vendor/#{library.name}/#{File.basename(file)}"
          sources_build_phase.add_build_file project.file("Vendor/#{library.name}/#{File.basename(file)}")
        end
        
        resources_build_phase = target.resources_build_phase
        
        library.files.reject {|file| File.extname(file) =~ /\.(mm?|h)$/ }.each do |file|
          Vendor.ui.info "#{target.name} # adding resources file: Vendor/#{library.name}/#{File.basename(file)}"
          resources_build_phase.add_build_file @project.file("Vendor/#{library.name}/#{File.basename(file)}")
        end
      
        framework_build_phase = target.framework_build_phase
      
        frameworks_added.each do |framework| 
          Vendor.ui.info "#{target.name} # adding build framework: #{framework.name}"
          framework_build_phase.add_build_file framework
        end
        
      end
    
      project.save!
      
    end
    
  end

end

module TempProject

  require 'fileutils'

  def self.cleanup
    FileUtils.rm_rf TEMP_PROJECT_PATH
    FileUtils.mkdir TEMP_PROJECT_PATH
  end

  def self.create(project_path)
    name = File.basename(project_path)
    location = File.join(TEMP_PROJECT_PATH, name)

    FileUtils.rm_rf location if Dir.exists?(location)

    FileUtils.cp_r project_path, TEMP_PROJECT_PATH

    location
  end

end

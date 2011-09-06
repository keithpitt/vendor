require 'rubygems'
require 'rspec'

require './lib/vendor_kit'

Dir["spec/support/**/*.rb"].each { |f| require "./#{f}" }

PROJECT_RESOURCE_PATH = File.join(File.dirname(__FILE__), "support", "resources", "projects")
FILE_RESOURCE_PATH = File.join(File.dirname(__FILE__), "support", "resources", "files")
VENDOR_RESOURCE_PATH = File.join(File.dirname(__FILE__), "support", "resources", "vendors")

TEMP_PROJECT_PATH = File.join(File.dirname(__FILE__), "..", "tmp")

TempProject.cleanup

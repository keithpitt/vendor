require 'rubygems'
require 'rspec'

require './lib/vendor'
require './lib/vendor/cli'

RESOURCE_PATH = File.join(File.dirname(__FILE__), "support", "resources")
PROJECT_RESOURCE_PATH = File.join(RESOURCE_PATH, "projects")
SOURCE_RESOURCE_PATH = File.join(RESOURCE_PATH, "source")
VENDOR_RESOURCE_PATH = File.join(RESOURCE_PATH, "vendors")
CACHED_VENDOR_RESOURCE_PATH = File.join(RESOURCE_PATH, "cache")
PACKAGED_VENDOR_PATH = File.join(RESOURCE_PATH, "packages")

TEMP_PROJECT_PATH = File.join(File.dirname(__FILE__), "..", "tmp")

Dir["spec/support/**/*.rb"].each { |f| require "./#{f}" }

TempProject.cleanup

Vendor::Config.directory = File.expand_path(File.join(__FILE__, "..", "..", "tmp", "config"))

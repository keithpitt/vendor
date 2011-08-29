require 'rubygems'
require 'rspec'
require 'fileutils'

require './lib/vendor_kit'

Dir["spec/support/**/*.rb"].each { |f| require "./#{f}" }

PROJECT_RESOURCE_PATH = File.join(File.dirname(__FILE__), "support", "resources", "projects")

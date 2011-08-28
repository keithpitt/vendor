require 'rspec'

require './lib/vendor'

Dir["spec/support/**/*.rb"].each { |f| require "./#{f}" }

RSpec.configure do |config|
  config.mock_with :rr
end

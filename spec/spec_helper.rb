$:.push File.expand_path("../../lib", __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
require 'cloudpt-api'
require 'rspec'

# If you wand to change the json, you can do it here
# I still believe yajl is the best :) - marcinbunsch
MultiJson.engine= :yajl

module Cloudpt
  Spec = Hashie::Mash.new
end

Dir.glob("#{File.dirname(__FILE__)}/support/*.rb").each { |f| require f }

# Clean up after specs, remove test-directory
RSpec.configure do |config|
  config.after(:all) do
    test_dir = Cloudpt::Spec.instance.find(Cloudpt::Spec.test_dir)
    test_dir.destroy unless test_dir.is_deleted?
  end
end


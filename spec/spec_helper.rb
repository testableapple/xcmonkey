$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'

# SimpleCov.minimum_coverage(80)
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'xcmonkey'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xcmonkey/version"

Gem::Specification.new do |spec|
  spec.name          = "xcmonkey"
  spec.version       = Xcmonkey::VERSION
  spec.authors       = ["alteral"]
  spec.email         = ["a.alterpesotskiy@mail.ru"]

  spec.summary       = "xcmonkey is a tool for doing randomised UI testing of iOS apps"
  spec.homepage      = "https://github.com/alteral/xcmonkey"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.bindir        = "bin"
  spec.executables   = ["xcmonkey"]
  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fasterer', '0.9.0')
  spec.add_development_dependency('fastlane')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '1.44.0')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-rake', '0.6.0')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('rubocop-rspec', '2.15.0')
  spec.add_development_dependency('simplecov')
  spec.add_dependency("colorize", "~> 0.8.1")
  spec.add_dependency("commander")
spec.metadata['rubygems_mfa_required'] = 'true'
end

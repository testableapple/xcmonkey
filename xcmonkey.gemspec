lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcmonkey/version'

Gem::Specification.new do |spec|
  spec.name          = 'xcmonkey'
  spec.version       = Xcmonkey::VERSION
  spec.authors       = ['testableapple']
  spec.email         = ['a.alterpesotskiy@mail.ru']

  spec.summary       = 'xcmonkey is a tool for doing randomised UI testing of iOS apps'
  spec.homepage      = 'https://github.com/testableapple/xcmonkey'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.bindir        = 'bin'
  spec.executables   = ['xcmonkey']
  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency('colorize', '>= 0.8.1', '< 1.1.0')
  spec.add_dependency('commander')

  spec.metadata['rubygems_mfa_required'] = 'true'
end

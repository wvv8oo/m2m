# coding: utf-8
lib = File.expand_path('./lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/product'

Gem::Specification.new do |spec|
  spec.executables   = ["m2m"]
  spec.name          = M2M::NAME
  spec.version       = M2M::VERSION
  spec.authors       = ["wvv8oo"]
  spec.email         = ["wvv8oo@gmail.com"]

  spec.summary       = %q{Markdown to More}
  spec.description   = %q{将Markdown转换为Blog，邮件或者PDF}
  spec.homepage      = M2M::HOMEPAGE

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = 'm2m'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_runtime_dependency('commander', '4.4.0')
  spec.add_runtime_dependency('nokogiri', '1.6.7')
  spec.add_runtime_dependency('mustache', '1.0.3')
  spec.add_runtime_dependency('kramdown', '1.10.0')
  spec.add_runtime_dependency('mail', '2.6.4')
end

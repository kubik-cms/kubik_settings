require_relative "lib/kubik_settings/version"

Gem::Specification.new do |spec|
  spec.name        = "kubik_settings"
  spec.version     = KubikSettings::VERSION
  spec.authors       = ["Bart Oleszczyk"]
  spec.email         = ["bart@primate.co.uk"]

  spec.summary       = "Settings module for Kubik CMS"
  spec.description   = "Active admin mixin to managing sitewide settings"
  spec.homepage      = "https://github.com/primate-inc/kubik_settings"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"
end

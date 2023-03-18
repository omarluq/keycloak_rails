# frozen_string_literal: true

require_relative 'lib/keycloak_rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'keycloak_rails'
  spec.version     = KeycloakRails::VERSION
  spec.required_ruby_version = '>= 2.6.0'
  spec.authors     = ['Omar Luqman']
  spec.email       = ['omaralanii@outlook.com']
  spec.homepage    = 'https://github.com/omarluq/keycloak_rails'
  spec.summary     = '%q{API wrapper for Key Cloak SSO server.}'
  spec.description = 'A rails wrapper for open source SSO project Keycloak.'
  spec.license     = 'MIT'
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'dry-configurable', '~> 0.16'
  spec.add_dependency 'faraday', '>= 2.0.0'
  spec.add_dependency 'jwt', '>= 2.4'
  spec.add_dependency 'rails', '>= 6.1.7'

  spec.add_development_dependency 'fasterer'
  spec.add_development_dependency 'overcommit'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-gitlab-security'
end

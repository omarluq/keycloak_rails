# frozen_string_literal: true

module KeycloakRails
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root(__dir__)
      def copy_initializer
        copy_file '../keycloak_rails.rb', 'config/initializers/keycloak_rails.rb'
      end
    end
  end
end

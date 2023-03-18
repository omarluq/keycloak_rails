# frozen_string_literal: true

module KeycloakRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root(__dir__)

      TABLE_NAME = 'keycloak_rails_sso'

      desc 'Generates a name space SSO model to store user subs.'

      def generate_keycloak_rails_model
        generate :migration, "create_#{TABLE_NAME}", 'recipient:references{polymorphic}', 'sub:string:index'
      end
    end
  end
end

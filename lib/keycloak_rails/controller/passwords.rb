# frozen_string_literal: true

module KeycloakRails
  # name space
  module Controller
    # controller helpers added to KeycloakRails passwords controller
    module Passwords
      extend ActiveSupport::Concern

      included do
        def reset_password(new_password:, new_password_confirmation:, email: current_user.email)
          raise StandardError, 'Passwords must match' unless new_password == new_password_confirmation

          keycloak_client.set_perm_password(email, new_password)
        end
      end
    end
  end
end

# frozen_string_literal: true

module KeycloakRails
  module SsoRecipient
    extend ActiveSupport::Concern

    included do
      has_one :keycloak_rails_sso, as: :recipient, class_name: '::KeycloakRails::Sso'

      def sub
        keycloak_rails_sso&.sub
      end
    end
  end
end

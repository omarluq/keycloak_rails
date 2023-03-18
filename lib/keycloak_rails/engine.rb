# frozen_string_literal: true

module KeycloakRails
  class Engine < ::Rails::Engine
    isolate_namespace(KeycloakRails)

    initializer('keycloack_rails', after: :load_config_initializers) do
      ActionController::Base.include KeycloakRails::Controller::Helpers
      ActionController::Base.include KeycloakRails::Controller::Sessions
      ActionController::Base.include KeycloakRails::Controller::Registrations
      ActionController::Base.include KeycloakRails::Controller::Passwords
      ActionController::Base.include KeycloakRails::Controller::MagicLinks if KeycloakRails.allow_magic_links
    end

    config.after_initialize do
      if KeycloakRails.user_model
        user_klass = KeycloakRails.user_model
        user_klass.singularize.classify.constantize.include KeycloakRails::SsoRecipient
      end
    end
  end
end

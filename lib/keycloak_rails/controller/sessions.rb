# frozen_string_literal: true

module KeycloakRails
  # name space
  module Controller
    # controller helpers added to KeycloakRails.sessions controller
    module Sessions
      extend ActiveSupport::Concern

      included do
        def start_sso_session(email, password)
          tokens = keycloak_user.fetch_tokens(email: email, password: password)
          set_auth_cookies(tokens)
          current_user
          redirect_to_app_root
        end

        def end_sso_session
          redirect_uri = url_for(only_path: false, overwrite_params: nil)
          keycloak_user.end_session(redirect_uri)
          destroy_current_user
          KeycloakRails.destroy_auth_cookies
          redirect_to_app_root
        end

        def redirect_to_app_root
          # redirect_back(fallback_location: root_path)

          redirect_to root_path, status: 301
        end
      end
    end
  end
end

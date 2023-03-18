# frozen_string_literal: true

module KeycloakRails
  # name space
  module Controller
    # controller helpers added to ActionController::Base class
    # only loaded if KeycloakRails.allow_magic_link = true
    module MagicLinks
      extend ActiveSupport::Concern

      included do
        def generate_magic_link(url:, email:, expiration_seconds: 3600, force_create: false, send_email: false,
                                client_id: KeycloakRails.client_id)
          magic_link_obj = keycloak_client.get_magic_link(email: email,
                                                          redirect_uri: url,
                                                          expiration_seconds: expiration_seconds,
                                                          force_create: force_create,
                                                          send_email: send_email,
                                                          client_id: client_id)
          magic_link_obj.except(force_create ? nil : 'user_id')
                        .except(send_email ? nil : 'sent')
        end

        def ensure_magic_link_code
          return false unless magic_link_params[:code] && magic_link_params[:session_state]
          return false unless login_by_handshake

          params.delete :code
          params.delete :session_state
          true
        end

        def login_by_handshake(persist_session: true)
          redirect_uri = url_for(only_path: false, overwrite_params: nil)
          tokens = keycloak_user.fetch_tokens_by_handshake(code: magic_link_params[:code], redirect_uri: redirect_uri)
          persist_session ? set_auth_cookies(tokens) : tokens
        end

        def client_user?
          !!current_user
        end

        def magic_link_params
          params.permit(:session_state, :code)
        end
      end
    end
  end
end

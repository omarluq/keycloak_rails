# frozen_string_literal: true

module KeycloakRails
  # name space
  module Controller
    # controller helpers added to ActionController::Base class
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :generate_magic_link, :current_user

        def initialize
          kick_start_auth_server_connection
          set_auth_cookies_procs
          set_destroy_auth_cookies
          super
        end

        def ensure_active_session(accept_magic_link_handshake: false)
          return if user_has_active_sso_session?(accept_magic_link_handshake: accept_magic_link_handshake)

          redirect_to root_path
        end

        def ensure_no_active_session
          redirect_to root_path if user_has_active_sso_session?
        end

        def user_has_active_sso_session?(accept_magic_link_handshake: false)
          (keycloak_client.current_user_has_active_session? && current_user) ||
            (accept_magic_link_handshake && ensure_magic_link_code)
        end

        def keycloak_client
          @keycloak_client ||= KeycloakRails::Client.new
        end

        def keycloak_user
          @keycloak_user ||= KeycloakRails::User.new
        end

        # need to think of away to capture the user model if we wanna set current_user
        # initial thought: use Dry::Configurable object defined on the Keycloak module to capture the model name and meta program my way from there
        def current_user
          @current_user ||= KeycloakRails::Sso.includes(:recipient).find_by(sub: keycloak_user.active_user_sub)&.recipient
          # have a join table keycloak_rails_subs sso_sub:string #{KeycloakRails.user_model}_id:refrence
          # to KeycloakRails.user_model.rb and add has_one :keycloak_rails_sub
          # delegate sso_sub to {KeycloakRails.user_model}
          #
        end

        def destroy_current_user
          @current_user = nil
        end

        def destroy_session_cookie
          cookies.permanent[:keycloak_session_token] = nil
        end

        def kick_start_auth_server_connection
          keycloak_client
          keycloak_user
        end

        def set_auth_cookies_procs
          KeycloakRails.session_cookie_proc = -> { session[:keycloak_session_token] }
          KeycloakRails.refresh_cookie_proc = -> { session[:keycloak_refresh_token] }
        end

        def set_auth_cookies(tokens)
          session[:keycloak_session_token] = tokens['access_token']
          session[:keycloak_refresh_token] = tokens['refresh_token']
          true
        end

        def set_destroy_auth_cookies
          KeycloakRails.destroy_session_cookie_proc = -> { session[:keycloak_session_token] = nil }
          KeycloakRails.destroy_refresh_cookie_proc = -> { session[:keycloak_refresh_token] = nil }
        end
      end
    end
  end
end

# frozen_string_literal: true

# requires all dependencies
require 'faraday'
require 'jwt'
require 'dry/configurable'

# requires all modules and classes
require 'keycloak_rails/version'
require 'keycloak_rails/engine'
require 'keycloak_rails/client'
require 'keycloak_rails/user'
require 'keycloak_rails/curl'
require 'keycloak_rails/controller/helpers'
require 'keycloak_rails/controller/magic_links'
require 'keycloak_rails/controller/omniauth'
require 'keycloak_rails/controller/passwords'
require 'keycloak_rails/controller/registrations'
require 'keycloak_rails/controller/sessions'
require 'keycloak_rails/controller/unlocks'
require 'app/models/keycloak_rails/sso'
require 'app/models/keycloak_rails/concerns/sso_recipient'

module KeycloakRails
  extend Dry::Configurable

  setting :user_model, reader: true
  setting :realm, reader: true
  setting :public_key, reader: true
  setting :auth_server_url, reader: true
  setting :secret, reader: true
  setting :client_id, reader: true
  setting :decode_token_strategy, reader: true, default: :local
  setting :signature_algo, reader: true
  setting :allow_magic_links, reader: true, default: false

  class << self
    attr_accessor :session_cookie_proc, :destroy_session_cookie_proc, :refresh_cookie_proc, :destroy_refresh_cookie_proc

    def current_session_cookie
      session_cookie_proc.call
    end

    def current_refresh_cookie
      refresh_cookie_proc.call
    end

    def destroy_auth_cookies
      destroy_session_cookie_proc.call
      destroy_refresh_cookie_proc.call
    end

    def openid_config
      @openid_config ||= fetch_openid_configuration
    end

    def fetch_openid_configuration
      request = Curl.new.get(path: "realms/#{realm}/.well-known/openid-configuration",
                             headers: { 'Content-Type': 'application/x-www-form-urlencoded' })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end
  end
end

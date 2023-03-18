# frozen_string_literal: true

module KeycloakRails
  # client lvl access to sso server established with client id and secret
  # can use basic auth or bearer client_token
  # perms for this lvl of access are controllered by sso server client roles
  class Client
    def initialize
      @curl = KeycloakRails::Curl.new
    end

    def create_user(email:, password:, first_name:, last_name:)
      request = @curl.post(path: "admin/realms/#{KeycloakRails.realm}/users",
                           headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                           body: { username: email, email: email, firstName: first_name, lastName: last_name,
                                   attributes: {}, groups: [], enabled: true }.to_json)
      raise StandardError, request[:response] unless request[:status] == :ok

      set_perm_password(email, password) unless password.nil? || password.empty?
      request[:response]
    end

    def current_user_has_active_session?
      KeycloakRails.current_session_cookie && current_cookie_active?
    end

    def current_cookie_active?
      token_introspection['active'] ? true : KeycloakRails.destroy_auth_cookies
    end

    # private

    def token_introspection
      request = @curl.post(path: KeycloakRails.openid_config['introspection_endpoint'],
                           headers: { 'Authorization': basic_auth_token,
                                      'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { "token": KeycloakRails.current_session_cookie })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def verify_email(user_id)
      request = @curl.put(path: "/admin/realms/#{KeycloakRails.realm}/users/#{user_id}",
                          headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                          body: { "emailVerified": true }.to_json)
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def update_user_attributes(user_id, attributes)
      request = @curl.put(path: "/admin/realms/#{KeycloakRails.realm}/users/#{user_id}",
                          headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                          body: attributes.to_json(only: attributes.keys))
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def require_set_otp(user_email)
      user = user_by_username(user_email)
      required_actions = user['requiredActions'].push('CONFIGURE_TOTP')
      request = @curl.put(path: "/admin/realms/#{KeycloakRails.realm}/users/#{user['id']}",
                          headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                          body: { "requiredActions": required_actions }.to_json)
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def set_perm_password(email, password)
      user = user_by_username(email)
      request = @curl.put(path: "/admin/realms/#{KeycloakRails.realm}/users/#{user['id']}/reset-password",
                          headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                          body: { 'type': 'password', 'temporary': false, 'value': password }.to_json)
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def get_magic_link(email:, redirect_uri:, expiration_seconds: 3600, force_create: false, send_email: false,
                       client_id: KeycloakRails.client_id)
      request = @curl.post(path: "/realms/#{KeycloakRails.realm}/magic-link",
                           headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                           body: { "email": email, "client_id": client_id,
                                   "redirect_uri": redirect_uri, "expiration_seconds": expiration_seconds,
                                   "force_create": force_create, "update_profile": force_create,
                                   "send_email": send_email }.to_json)
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def user_by_username(email)
      request = @curl.get(path: "admin/realms/#{KeycloakRails.realm}/users?username=#{email}&exact=true",
                          headers: { 'Authorization': client_token, 'Content-Type': 'application/json' },
                          body: { username: email, exact: true }.to_json)

      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]&.first
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{KeycloakRails.client_id}:#{KeycloakRails.secret}")}"
    end

    #  <---- USE WISELY!!!! ----->
    def client_token
      "bearer #{fetch_client_token['access_token']}"
    end

    def fetch_client_token
      request = @curl.post(path: "realms/#{KeycloakRails.realm}/protocol/openid-connect/token",
                           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { 'grant_type': 'client_credentials', 'client_id': KeycloakRails.client_id,
                                   'client_secret': KeycloakRails.secret })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end
  end
end

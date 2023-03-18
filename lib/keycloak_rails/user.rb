# frozen_string_literal: true

module KeycloakRails
  # User lvl access to sso server established session_token after auth with username and password
  # min perms
  class User
    def initialize
      @curl = KeycloakRails::Curl.new
    end

    def fetch_tokens(email:, password:, otp_password: nil)
      request = @curl.post(path: KeycloakRails.openid_config['token_endpoint'],
                           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { 'grant_type': 'password', 'client_id': KeycloakRails.client_id,
                                   'client_secret': KeycloakRails.secret, 'username': email,
                                   'password': password }.merge((otp_password ? { 'totp': otp_password } : {})))
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def fetch_tokens_by_handshake(code:, redirect_uri:)
      request = @curl.post(path: KeycloakRails.openid_config['token_endpoint'],
                           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { 'grant_type': 'authorization_code', 'client_id': KeycloakRails.client_id,
                                   'client_secret': KeycloakRails.secret, code: code,
                                   "redirect_uri": redirect_uri })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def fetch_current_user_info
      request = @curl.post(path: KeycloakRails.openid_config['userinfo_endpoint'],
                           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { access_token: access_token })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    def end_session(redirect_uri)
      request = @curl.post(path: KeycloakRails.openid_config['end_session_endpoint'],
                           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                           body: { 'client_id': KeycloakRails.client_id,
                                   'client_secret': KeycloakRails.secret,
                                   'refresh_token': KeycloakRails.current_refresh_cookie,
                                   'post_logout_redirect_uri': redirect_uri })
      raise StandardError, request[:response] unless request[:status] == :ok

      request[:response]
    end

    # gets user sub by making an api call to auth server
    def fetch_active_user_sub
      fetch_current_user_info['sub']
    end

    # gets user sub by decoding the session_cookie
    def decode_active_user_sub
      decoded_access_token.first['sub']
    end

    def active_user_sub
      return unless access_token

      case KeycloakRails.decode_token_strategy
      when :local then decode_active_user_sub
      when :cloud then fetch_active_user_sub
      end
    end

    # private

    def access_token
      KeycloakRails.current_session_cookie
    end

    def decoded_access_token
      decode(access_token)
    end

    def decoded_refresh_token
      decode(refresh_token)
    end

    def decode(token)
      JWT.decode token, KeycloakRails.public_key, false, { algorithm: KeycloakRails.signature_algo }
    end
  end
end

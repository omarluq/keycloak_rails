# frozen_string_literal: true

# Keycloak Rails initializer

KeycloakRails.configure do |config|
  ####################################################
  # config options
  # decode token strategy can be :local or :cloud
  # config.decode_token_strategy = :local
  # config.signature_algo = 'RS256'
  # config.allow_magic_links = true
  ####################################################
  # Rails app models
  # config.user_model = 'user'
  ####################################################
  # Auth server info
  # config.auth_server_url = ''
  # config.realm = 'realm'
  # only needed if decode_token_strategy = :local
  # config.public_key = "public_key"
  # config.secret = ''
  # config.client_id = 'client_id'
  ####################################################
end

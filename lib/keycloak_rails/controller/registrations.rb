# frozen_string_literal: true

module KeycloakRails
  # name space
  module Controller
    # controller helpers added to KeycloakRails.registrations controller
    module Registrations
      extend ActiveSupport::Concern

      included do
        def create_or_find_sso_user(email:, first_name:, last_name:, password_confirmation: nil, set_session: true, password: nil)
          user = keycloak_client.user_by_username(email)
          if user
            { sso_sub: user['id'], email: email,
              first_name: first_name, last_name: last_name }
          else
            create_sso_user(email: email, password: password, first_name: first_name, last_name: last_name,
                            password_confirmation: password_confirmation, set_session: set_session)
          end
        end

        def create_sso_user(email:, first_name:, last_name:, password_confirmation: nil, set_session: true, password: nil)
          raise StandardError, 'Passwords must match' if password_confirmation && password != password_confirmation

          keycloak_client.create_user(email: email,
                                      password: password,
                                      first_name: first_name,
                                      last_name: last_name)
          if set_session
            tokens = keycloak_user.fetch_tokens(email: email, password: password)
            set_auth_cookies(tokens)
          end
          user_sub = keycloak_client.user_by_username(email)['id']
          { sso_sub: user_sub, email: email,
            first_name: first_name, last_name: last_name }
        end

        def update_sso_record_attributes(user_sub, attributes)
          attributes = attributes.transform_keys { |key| key.to_s.camelize(:lower) }
          keycloak_client.update_user_attributes(user_sub, attributes)
        end

        def mark_email_verified(user_sub)
          keycloak_client.verify_email(user_sub)
        end
      end
    end
  end
end

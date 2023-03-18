# frozen_string_literal: true

module KeycloakRails
  class Sso < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
  end
end

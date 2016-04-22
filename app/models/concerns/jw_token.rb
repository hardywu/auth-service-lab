# module for model with JWT
module JWToken
  extend ActiveSupport::Concern
  class AuthError < StandardError
  end

  included do
    attr_writer :payload
  end

  class_methods do
    def find_by_pw_reset_jwt(token)
      find_by_jwt token
    end

    def find_by_confirmation_jwt(token)
      find_by_jwt token
    end

    def find_by_jwt(token)
      payloader = decode_jwt token
      find payloader[0]['id']
    rescue JWT::DecodeError
      nil
    end

    def decode_jwt(token, key = Rails.application.secrets['secret_key_base'])
      JWT.decode token, key
    end
  end

  def jwt(hash = payload, key = Rails.application.secrets['secret_key_base'])
    JWT.encode hash, key, 'HS384'
  end

  def payload
    @payload ||= default_payload
  end

  private

  def default_payload
    {
      id: id,
      sub: id,
      iat: Time.now.to_i,
      exp: Time.now.to_i + 24 * 3600
    }
  end
end

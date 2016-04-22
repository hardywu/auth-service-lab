# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string
#  password_digest    :string
#  phone              :string
#  pin_digest         :string
#  sign_in_count      :integer          default("0"), not null
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# User Model
class User < ApplicationRecord
  include BCrypt
  include JWToken

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end

  def pin=(pin)
    @pin = Password.create(pin)
    self.pin_digest = @pin
  end

  def pin
    @pin ||= Password.new(pin_digest)
  end

  def self.find_and_authenticate_by(arg = {})
    case arg[:credential_type]
    when 1
      User.find_and_auth_by_pc email: arg[:email], password: arg[:password]
    when 2
      User.find_and_auth_by_mobile phone: arg[:phone], pin: arg[:pin]
    end
  end

  def self.find_and_auth_by_mobile(phone:, pin:)
    user = User.find_by phone: phone
    raise AuthError, 'Invalid credential' unless user.try(:pin) == pin
    user
  end

  def self.find_and_auth_by_pc(email:, password:)
    user = User.find_by email: email
    raise AuthError, 'Invalid credential' unless user.try(:password) == password
    user
  end
end

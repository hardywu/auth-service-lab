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

class User < ApplicationRecord
  include BCrypt
  include Jwtoken

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
end

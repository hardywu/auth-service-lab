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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "create user with email/password" do
    user = User.new email: 'test@email.com', password: 'changeit'
    assert user.save
    assert user.password == 'changeit'
    assert_not user.password == 'wrongpwd'
  end

  test "create user with phone/pin" do
    user = User.new phone: '5555555555', pin: '1234'
    assert user.save
    assert user.pin == '1234'
    assert_not user.pin == '0000'
  end
end

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @desktop_user = users(:desktop_one)
    @mobile_user = users(:mobile_one)
    @headers = { 'Content-Type' => 'application/json' }
  end

  def email_credential
    {
      credential_type: 1,
      email: @desktop_user.email,
      password: "password",
      scope: "desktop"
    }
  end

  def phone_credential
    {
      credential_type: 2,
      phone: @mobile_user.phone,
      pin: "4566",
      scope: "mobile"
    }
  end

  test "login with email/password" do
    post login_url, params: email_credential.to_json, headers: @headers
    assert_match 'token', @response.body

    reply = JSON.parse @response.body
    user = User.find_by_jwt reply['data']['token']
    assert_equal user.id, @desktop_user.id
  end

  test "login with phone/pin" do
    post login_url, params: phone_credential.to_json, headers: @headers
    assert_match 'token', @response.body

    reply = JSON.parse @response.body
    user = User.find_by_jwt reply['data']['token']
    assert_equal user.id, @mobile_user.id
  end
end

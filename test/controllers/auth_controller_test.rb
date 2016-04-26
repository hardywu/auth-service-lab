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

  test "login with wrong pin" do
    cred = phone_credential
    cred[:pin] = '0000'
    post login_url, params: cred.to_json, headers: @headers

    assert_response :unauthorized
    assert_match 'errors', @response.body
    assert_match 'AuthError', @response.body
  end

  test "login with non-existing email" do
    cred = email_credential
    cred[:email] = 'not@found.com'
    post login_url, params: cred.to_json, headers: @headers

    assert_response :unauthorized
    assert_match 'errors', @response.body
    assert_match 'AuthError', @response.body
  end

  test "login with wrong credential_type" do
    cred = email_credential
    cred[:credential_type] = 3
    post login_url, params: cred.to_json, headers: @headers

    assert_response :unauthorized
    assert_match 'errors', @response.body
    assert_match 'AuthError', @response.body
  end

  test "refresh token with an old one" do
    get token_refresh_url, params: { token: @mobile_user.jwt }
    assert_match 'token', @response.body

    # check expiration time is refreshed
    reply = JSON.parse @response.body
    payloader = User.decode_jwt reply['data']['token']
    assert payloader[0]['exp'] > 23 * 3600 + Time.now.to_i
  end

  test "refresh token with an expired one" do
    token = @mobile_user.jwt
    Timecop.freeze(Time.zone.today + 2) do
      get token_refresh_url, params: { token: token }

      assert_response :unauthorized
      assert_match 'errors', @response.body
      assert_match 'AuthError', @response.body
    end
  end
end

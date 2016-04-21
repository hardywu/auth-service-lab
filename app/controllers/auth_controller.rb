class AuthController < ApplicationController
  class AuthError < StandardError
  end

  rescue_from AuthError, with: :render_auth_error
  rescue_from JWT::ExpiredSignature, with: :render_auth_error

  def login
    auth_login_user
    render json: { data: { token: @user.jwt } }
  end

  def refresh
    payloader = User.decode_jwt params[:token]
    user = User.find payloader[0]['id']
    user.payload['scope'] = payloader[0]['scope']
    render json: { data: { token: user.jwt } }
  end

  private

  def auth_login_user
    @user = User.find_and_authenticate_by login_params
    raise AuthError, 'Invalid credential' unless @user
    @user.payload['scope'] = params[:scope]
  end

  def login_params
    params.permit(:credential_type, :email, :password, :phone, :pin)
  end

  def render_auth_error(error)
    render json: { errors: [{ id: 'AuthError', detail: error.message }] },
           status: :unauthorized
  end
end

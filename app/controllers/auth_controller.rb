class AuthController < ApplicationController
  rescue_from JWToken::AuthError, with: :render_auth_error
  rescue_from JWT::ExpiredSignature, with: :render_auth_error

  def login
    auth_user
    render json: { data: { token: @user.jwt } }
  end

  def mobile_login
    auth_mobile_user
    render json: { data: { token: @user.jwt } }
  end

  def refresh
    payloader = User.decode_jwt params[:token]
    user = User.find payloader[0]['id']
    user.payload['scope'] = payloader[0]['scope']
    render json: { data: { token: user.jwt } }
  end

  private

  def auth_user
    @user = credential_class.find_and_authenticate_by login_params
    @user.payload['scope'] = params[:scope]
  end

  def credential_class
    user_classes = { 1 => User, 2 => MobileUser }
    user_classes[params[:credential_type]]
  end

  def login_params
    params.permit(:email, :password, :phone, :pin)
  end

  def render_auth_error(error)
    render json: { errors: [{ id: 'AuthError', detail: error.message }] },
           status: :unauthorized
  end
end

class AuthController < ApplicationController
  class AuthError < StandardError
  end

  rescue_from AuthError, with: :render_auth_error

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
    case params[:credential_type]
    when 1
      @user = User.find_by! email: params[:email]
      unless @user.password == params[:password]
        raise AuthError, 'Invalide email/password combination'
      end
    when 2
      @user = User.find_by! phone: params[:phone]
      unless @user.pin == params[:pin]
        raise AuthError, 'Invalide phone/pin combination'
      end
    else
      raise AuthError, 'Invalide credential type'
    end
    @user.payload['scope'] = params[:scope]
  end

  def render_auth_error(error)
    render json: { errors: [{ id: 'AuthError', detail: error.message }] },
           status: status
  end
end

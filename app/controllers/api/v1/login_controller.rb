class API::V1::LoginController < ApplicationController
  respond_to :json
  skip_before_action :require_login

  def create
    user = User.find_for_authentication(email: params[:email])

    if user.valid_password?(params[:password])
      token = JwtService.issue({user_id: user.id, exp: exp})

      render json: {token: token, exp: exp}, status: 200
    else
      render json: {error: login_error}, status: 422
    end
  rescue
    render json: {error: login_error}, status: 422
  end

  private

  def login_error
    I18n.t('errors.login.failure')
  end

  def exp
    (Time.now + 1.day).to_i
  end
end

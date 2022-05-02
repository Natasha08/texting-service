class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::Cookies

  respond_to :json
  before_action :require_login

  DECODE_EXCEPTIONS = [JWT::VerificationError, JWT::DecodeError]

  private

  def valid_token?
    !!current_user_id
  end

  def token
    header = request.headers["Authorization"]
    header.split('Bearer ').last
  rescue NoMethodError
    return nil
  end

  def decoded_token
    begin
      JwtService.verify token

    rescue *DECODE_EXCEPTIONS => e
      puts "DECODING ERROR: ", e
      return nil
    end
  end

  def current_user_id
    return nil if token_expired?

    decoded_token["user_id"] if decoded_token.present?
  end

  def set_channel_cookie
    cookies.encrypted[:user_id] = current_user_id
  end

  def require_login
    render json: {error: 'Unauthorized'}, status: :unauthorized if !valid_token?
    set_channel_cookie
  end

  def current_user
    User.find current_user_id
  end

  def token_expired?
    Time.now.to_i > decoded_token["exp"].to_i if decoded_token.present?
  end
end

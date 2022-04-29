class ApplicationController < ActionController::API
  include RackSessionFix
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

  def current_user_id
    begin
      payload = JwtService.verify token

    rescue *DECODE_EXCEPTIONS => e
      puts "DECODING ERROR: ", e
      return nil
    end

    payload["user_id"] if payload.present?
  end

  def require_login
    render json: {error: 'Unauthorized'}, status: :unauthorized if !valid_token?
  end

  def current_user
    User.find current_user_id
  end
end

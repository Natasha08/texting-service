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
  end

  def current_user_id
    begin
      payload = JwtService.verify token

    rescue *DECODE_EXCEPTIONS => e
      puts "DECODING ERROR: ", e
      return nil
    end

    payload["user_id"]
  end

  def require_login
    render json: {error: 'Unauthorized'}, status: :unauthorized if !valid_token?
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    DECODE_EXCEPTIONS = [JWT::VerificationError, JWT::DecodeError, NoMethodError].freeze

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      header_array = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(',')
      token = header_array[header_array.length - 1]
      decoded_token = JwtService.verify token.strip
      current_user = User.find((decoded_token["user_id"]))

      current_user || reject_unauthorized_connection
    rescue *DECODE_EXCEPTIONS
      reject_unauthorized_connection
    end
  end
end

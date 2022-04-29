class JwtService
  def self.issue payload
    JWT.encode payload, secret_key
  end

  def self.verify token
    if token.present?
      JWT.decode(token, secret_key, true).first&.with_indifferent_access
    end
  end

  def self.secret_key
    Rails.application.secret_key_base
  end
end

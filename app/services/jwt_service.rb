class JwtService
  def self.issue payload
    JWT.encode(payload, secret_key, 'HS256')
  end

  def self.verify token
    if token.present?
      JWT.decode(token, secret_key, true, { algorithm: 'HS256' }).first&.with_indifferent_access
    end
  end

  private
  def self.secret_key
    ENV["JWT_SECRET_KEY"]
  end
end

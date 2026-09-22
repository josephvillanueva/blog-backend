# Signs and verifies the JSON Web Tokens used for API authentication.
# The secret comes from JWT_SECRET, falling back to the app's secret_key_base.
class AuthToken
  TTL = 24.hours

  def self.encode(user_id, expires_at: TTL.from_now)
    JWT.encode({ user_id: user_id, exp: expires_at.to_i }, secret, "HS256")
  end

  # Returns the payload hash, or nil for a missing, tampered, or expired token.
  def self.decode(token)
    return nil if token.blank?

    JWT.decode(token, secret, true, algorithm: "HS256").first
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
end

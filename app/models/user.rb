class User < ApplicationRecord
  PUBLIC_FIELDS = %i[id username created_at].freeze
  PRIVATE_FIELDS = %i[id username email created_at].freeze

  has_secure_password
  has_many :blogs, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :username, presence: true, length: { maximum: 30 }, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # Never serialize the password digest or email unless a caller asks for them.
  def as_json(options = nil)
    super({ only: PUBLIC_FIELDS }.merge(options || {}))
  end
end

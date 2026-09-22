class Blog < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  before_validation :normalize_tags

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :published, -> { where(status: "published") }
  scope :visible_to, ->(user) { user ? published.or(where(user_id: user.id)) : published }
  scope :tagged, ->(tag) { where("? = ANY (tags)", tag.to_s.strip.downcase) }

  # Adds score and comments_count in one query instead of one per post.
  scope :with_stats, lambda {
    select(
      "blogs.*",
      "COALESCE((SELECT SUM(votes.value) FROM votes WHERE votes.blog_id = blogs.id), 0) AS score",
      "(SELECT COUNT(*) FROM comments WHERE comments.blog_id = blogs.id) AS comments_count"
    )
  }

  def as_json(_options = nil)
    {
      id: id,
      title: title,
      body: body,
      status: status,
      tags: tags,
      author: { id: user_id, username: user.username },
      score: has_attribute?(:score) ? self[:score].to_i : votes.sum(:value),
      comments_count: has_attribute?(:comments_count) ? self[:comments_count].to_i : comments.count,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def normalize_tags
    self.tags = Array(tags).map { |tag| tag.to_s.strip.downcase }.reject(&:blank?).uniq
  end
end

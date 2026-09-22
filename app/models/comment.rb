class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :blog

  validates :body, presence: true, length: { maximum: 2000 }

  def as_json(_options = nil)
    {
      id: id,
      blog_id: blog_id,
      body: body,
      author: { id: user_id, username: user.username },
      created_at: created_at,
      updated_at: updated_at
    }
  end
end

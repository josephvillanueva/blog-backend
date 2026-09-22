class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :blog

  validates :value, inclusion: { in: [-1, 1], message: "must be 1 or -1" }
  validates :user_id, uniqueness: { scope: :blog_id }
end

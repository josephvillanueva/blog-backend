class Comment < ApplicationRecord
  belongs_to :user, :blog
  has_one :vote, dependent: :destroy
end

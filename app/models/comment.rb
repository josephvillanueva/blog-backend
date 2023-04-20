class Comment < ApplicationRecord
  belongs_to :user
  has_one :vote, dependent: :destroy
end

class Comment < ApplicationRecord
  belongs_to :user
  has_many :vote
end

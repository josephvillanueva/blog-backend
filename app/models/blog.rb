class Blog < ApplicationRecord
  belongs_to :user
  has_one :vote, dependent: :destroy
end

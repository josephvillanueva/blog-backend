class Vote < ApplicationRecord
    belongs_to :user, :blog
end

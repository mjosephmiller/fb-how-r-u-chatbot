class User < ActiveRecord::Base
    has_many :mood_reviews, dependent: :destroy
end

class User < ApplicationRecord
    has_secure_password
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } 

    has_many :received_follows, foreign_key: :followed_user_id, class_name: "Follow"
    has_many :followers, through: :received_follows, source: :follower

    has_many :given_follows, foreign_key: :follower_id, class_name: "Follow"
    has_many :followings, through: :given_follows, source: :followed_user
end

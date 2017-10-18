class Achivment < ApplicationRecord
  has_many :users, through: :user_achivments
  has_many :user_achivments
end

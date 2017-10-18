class User < ApplicationRecord
  belongs_to :division
  has_many :reports
  has_many :achivments, through: :user_achivments
  has_many :user_achivments
end

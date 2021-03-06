class Achivment < ApplicationRecord
  has_many :users, through: :user_achivments
  has_many :user_achivments
  scope :no_obtain_for, ->(user) { Achivment.where(public: true) - user.achivments }

  def update_percentage
    update_attributes(percentage: 100.0 * users.count / User.count)
  end

  def self.update_percentage
    Achivment.all.each { |a| a.update_percentage }
  end

  def show?
    percentage > 33
  end
end

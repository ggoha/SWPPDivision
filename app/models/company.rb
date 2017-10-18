class Company < ApplicationRecord
  has_many :battle_results
  has_many :stocks
  has_many :users
  has_many :divisions

  def default_division
    divisions.first
  end
end

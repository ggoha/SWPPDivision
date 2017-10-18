class Division < ApplicationRecord
  belongs_to :company
  has_many :users
  has_many :admins, through: :admin_divisions
  has_many :admin_divisions
end

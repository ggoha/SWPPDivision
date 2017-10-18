class BattleResult < ApplicationRecord
  belongs_to :company
  belongs_to :battle
  has_many :reports
end

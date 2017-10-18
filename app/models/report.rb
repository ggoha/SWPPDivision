class Report < ApplicationRecord
  belongs_to :user
  belongs_to :battle_result
end

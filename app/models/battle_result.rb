class BattleResult < ApplicationRecord
  belongs_to :company
  belongs_to :battle
  has_many :reports

  before_save :update_summary_score
  after_save :update_sadness

  default_scope { order(:at) }
  
  def update_summary_score
    self.summary_score = company.score + score
    company.update_attributes(score: summary_score)
  end

  def update_sadness
    company.update_attributes(sadness: result ? 0 : [company.sadness + 1, 5].min)
  end

  def losses
    money.positive? ? 0 : -money
  end
end

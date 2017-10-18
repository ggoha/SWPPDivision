class User < ApplicationRecord
  belongs_to :division
  has_many :reports
  has_many :achivments, through: :user_achivments
  has_many :user_achivments

  def self.create_from(message)
    d = Division.find_or_default(message)
    user = d.users.create(telegram_id: message['from']['id'],
                          company_id: d.company_id,
                          username: message['from']['username'],
                          game_name: message['text'].scan(/(🎩|🤖|⚡️|☂️|📯)?(.+) \(/)[0][1])
    Achivment.update_percentage
    user
  end

  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? find_by_telegram_id(message['from']['id']) : create_from(message)
  end
end

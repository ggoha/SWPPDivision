class AddBasicModel < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :smile, null: false
      t.string :title, null: false
      t.integer :score, null: false, default: 0
      t.integer :sadness, null: false, default: 0
    end
    create_table :stocks do |t|
      t.integer  :company_id, null: false
      t.integer  :price, null: false
      t.datetime :at, null: false
    end
    create_table :divisions do |t|
      t.string  :title, null: false
      t.string  :telegram_id
      t.integer :company_id, null: false
      t.boolean :autopin, default: false
      t.string  :message,        default: '15 минут до взлома, не забудьте поесть и слить деньги в акции'
      t.boolean :autopin_nighty, default: false
      t.string  :nighty_message, default: 'Проверьте автосон, ловите биржевиков, приходите завтра на взлом'
    end
    create_table :battles do |t|
      t.datetime :at, null: false
      t.text     :raw, null: false
    end
    create_table :battle_results do |t|
      t.integer  :company_id, null: false
      t.integer  :battle_id, null: false
      t.integer  :score, null: false
      t.integer  :summary_score
      t.integer  :money
      t.integer  :current_sadness
      t.float    :percent_score
      t.boolean  :result
    end
   create_table :users do |t|
      t.string   :game_name, null: false
      t.string   :telegram_id, null: false
      t.string   :username, null: false
      t.integer  :division_id, null: false
      t.integer  :practice
      t.integer  :theory
      t.integer  :cunning
      t.integer  :wisdom
      t.integer  :rage, null: false, default: 0
      t.integer  :level
      t.integer  :stars
      t.integer  :endurance
      t.integer  :experience
      t.integer  :motivation
      t.string   :type, null: false, default: 'User'
      t.integer  :mvp,               default: 0
      t.datetime :profile_update_at
      t.datetime :endurance_update_at
      t.datetime :last_remind_at,    default: DateTime.now
    end
    create_table :reports do |t|
      t.integer :user_id, null: false
      t.integer :battle_result_id, null: false
      t.integer :broked_company_id, null: false
      t.integer :kill
      t.integer :money
      t.integer :score
      t.boolean :active
      t.float   :comrades_percentage 
    end
  end
end

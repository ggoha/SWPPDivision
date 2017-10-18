  def message_type 
    return :parse_battle unless message['text'].scan(/По итогам битвы/).empty?
    return :parse_stock unless message['text'].scan(/👍Акции всех|👎На рынке/).empty?
    return :parse_totals unless message['text'].scan(/Рейтинг компаний за день/).empty?
  end

  def parse_stock(message)
    text = message['text']
    prices = text.scan(/(\d+) 💵(\n\n|.)/).map { |price| price[0].split(' ')[0] }
    name = name(message)
    Company.all.each_with_index do |company, i|
      company.stocks.create(price: prices[i], name: name, at: Time.at(message['date']))
    end
  end

  def parse_battle(message)
    text = message['text']
    battle = Battle.create(at: Time.at(message['date']), raw: text)

    monies, scores, results = [], [], []
    # Деньги
    text.scan(/(отобрали|утащили|собой)(.+)/).each do |substr|
      if substr[0] == 'собой'
        results << false
        monies << 0
        next
      end
      results << (substr[0] == 'отобрали')
      monies << ((substr[0] == 'утащили') ? -to_int(substr[1]) : to_int(substr[1]))
    end
    # Очки
    text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+)🏆/).each do |substr|
      name, score = substr[1].split('+')
      scores[NAME[name.strip]] = to_int(score)
    end
    # Проценты
    full_scores = scores.inject(0, :+)
    percent_scores = scores.map { |score| score.to_f / full_scores * 100 }
    # Текущая грусть
    Company.all.each_with_index do |company, i|
      company.battle_results.create(score: scores[i], percent_score: percent_scores[i], result: results[i], money: monies[i], battle: battle)
    end
  end

  def parse_totals(message)
    text = message['text']
    result_str = ''
    scores = {}
    text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+)🏆/).each do |substr|
      name, score = substr[1].split('-')
      scores[NAME[name.strip]] = to_int(score)
    end
    Company.all.each_with_index do |company, i|
      result_str << "#{company.title}: #{scores[i]} - #{company.  score}\n"
    end
    result_str
  end

  def message_type(message)
    return :parse_invite if message['new_chat_member'].present?
    return :parse_undefined unless message['text']
    if from_startup_wars?(message)
      return :parse_report if message['text'].include?('Твои результаты в битве')
      return :parse_full_profile if message['text'].include?('До следующей Битвы')
      return :parse_compact_profile if message['text'].include?('Полный профиль')
      return :parse_endurance if message['text'].include?('🔋Выносливость:')
    end
    return :parse_bag if message['text'].include?('#SWОтделыБаг')
    return :parse_feature if message['text'].include?('#SWОтделыИдея')
    :parse_undefined
  end



  def check_user(user, text)
    username = text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+) \(/)[0][1]
    user && user.game_name == username
  end

  def check_profile_actual(user, message)
    user.profile_update_at && user.profile_update_at > message['forward_date']
  end 

  def get_regexp(text, regexp)
    text.scan(regexp)[0][0] if text.scan(regexp)[0]
  end

  def practice_buff(practice, user)
    (practice.to_f / user.practice - 1) * 100 / (0.6 * (1 + user.rage * 0.2))
  end

  def theory_buff(theory, user)
    (theory.to_f / user.theory - 1) * 100 / (1.6 * (1 + user.rage * 0.2))
  end

  def buff(message, user)
    return nil unless message['text'].include?('🔨')
    return nil unless user.theory && user.practice
    current_practice = to_int get_regexp(message['text'], /🔨(.+)🎓/)
    current_theory = to_int get_regexp(message['text'], /🎓(.+)🐿/)
    message['text'].include?('Ты защищал') ? theory_buff(current_theory, user) : practice_buff(current_practice, user)
  end


  def endurances(text)
    text.scan(/🔋Осталось выносливости: (\d+)%/)[0] ? (text.scan(/🔋Осталось выносливости: (\d+)%/)[0][0]).to_i : 0
  end

  def parse_feature(message)
    me = Rails.application.secrets['telegram']['me']
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: me
    respond_with :message, text: t('.parse_feature.content')
  end

  def parse_bag(message)
    me = Rails.application.secrets['telegram']['me']
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: me
    respond_with :message, text: t('.parse_bag.content')
  end

  def parse_invite(message)
    return unless message['new_chat_member']['id'] == Rails.application.secrets['telegram']['bots']['division']['id']
    user = User.find_by_telegram_id(message['from']['id'])
    unless user
      respond_with :message, text: 'Отдел не созданн, для создания отдела вам предварительно надо отправить профиль боту в личку'
      return
    end
    Division.find_or_create(message, user)
  end

  def parse_full_profile(message)
    text = message['text']
    
    user = User.find_or_create(message)
    if check_profile_actual(user, message)
      respond_with :message, text: 'Уже обработан более поздний профиль' and return
    end
    params = {}
    params[:game_name] = 
    params[:practice] = get_regexp(text, /Практика:.+\((\d+)\)/)
    params[:theory] = get_regexp(text, /Теория:.+\((\d+)\)/)
    params[:cunning] = get_regexp(text, /Хитрость:.+\((\d+)\)/)
    params[:wisdom] = get_regexp(text, /Мудрость:.+\((\d+)\)/)
    params[:stars] = (get_regexp(text, /Крутизна: (.+)\/cool/).length - 1) / 2
    params[:level] = get_regexp(text, /Уровень: (\d+)/)
    params[:experience] = to_int(get_regexp(text, /Опыт: (.+) из/))
    params[:motivation] = motivations(message)
    user.update_profile(params)

    endurance = get_regexp(text, /Выносливость: (\d+)%/)
    user.update_endurance(endurance)
    respond_with :message, text: 'Профиль обработан'
  end

  def parse_compact_profile(message)
    text = message['text']
    
    user = User.find_or_create(message)
    if check_profile_actual(user, message)
      respond_with :message, text: 'Уже обработан более поздний профиль' and return
    end
    params = {}
    params[:game_name] = get_regexp(text, /\n\n💰?(.*) \(/)
    params[:practice] = to_int get_regexp(text, /🔨(.+)🎓/)
    params[:theory] = to_int get_regexp(text, /🎓(.+)/)
    params[:cunning] = to_int get_regexp(text, /🐿(.+)🐢/)
    params[:wisdom] = to_int get_regexp(text, /🐢(.+)/)
    params[:stars] = (get_regexp(text, /(.+)\/cool/).length - 1) / 2
    params[:level] = get_regexp(text, /🎚(\d+) \(/)
    params[:experience] = to_int get_regexp(text, /\((.+) из/)
    params[:motivation] = to_int get_regexp(text, /из (\d+) \(/)
    user.update_profile(params)

    endurance = get_regexp(tetx, /🔋(\d+)%/)
    user.update_endurance(endurance)
    respond_with :message, text: 'Профиль обработан'
  end

  def parse_report(message)
    text = message['text']
    user = User.find_or_create(message)
    if !check_user    
      respond_with :message, text: 'Репорт не обработан, пользователь не совпадает' and return
    end
    if text.scan(/(Ты защищал|Ты взламывал) (.+)/).empty?
      respond_with :message, text: 'Репорт не обработан, необходимо добавить компанию, которую ты вламывал' and return
    end
    battle_result = user.company.battle_results.last
    if battle_result.battle.at.hour.to_s != get_regexp(text, /на (\d+) часов/)
      respond_with :message, text: 'Репорт не обработан, битва не найдена' and return
    end
    broked_company_id = NAME_SMILE[text.scan(/(Ты защищал|Ты взламывал) (.+)/)[0][1]]
    kill = COUNT[text.scan(/(Тебе не удалось|Ты вынес|Ты выпилил сразу|Тебе удалось выбить сразу|Ты уронил аж) ([а-яё]+)/)[0][1]]
    money = text.scan(/Деньги: (.+)\n/)[0] ? text.scan(/Деньги: (.+)\n/)[0][0].delete('$').to_i : 0 
    score = text.scan(/Твой вклад: (.+)\n/)[0] ? text.scan(/Твой вклад: (.+)\n/)[0][0].to_i : 0
    endurance = endurances(message)
    buff = buff(message, user)
    user.reports.create(battle_result: battle_result, broked_company_id: broked_company_id, kill: kill, money: money, score: score, buff: buff)
    user.update_endurance(endurance)
    respond_with :message, text: 'Репорт обработан'
  end

  def parse_endurance(message)
    user = User.find_or_create(message)
    endurance = get_regexp(message['text'], /🔋Выносливость: (\d+)%/)
    user.update_endurance(endurance)
    respond_with :message, text: 'Сообщение о еде обработано'
  end

module ApplicationHelper
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️', 5 => '🎩' }.freeze
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }.freeze

  def id(user)
    '🆔'+user.id.to_s.ljust(3, '_')
  end

  def level(user)
    '🎚'+user.level.to_s.ljust(2, '_')
  end

  def stars(user)
    user.stars ? '⭐️' * user.stars + '🚫' * (3 - user.stars) : '🚫' * 3
  end

  def last_update(user)
    '⏱' + user.profile_update_at ? user.profile_update_at.strftime("%H-%d") : '##-##'
  end

  def endurance(user)
    if user.endurance_update_at && user.endurance_update_at >= Battle.last.at
      '🔋'+user.endurance.to_s
    else
      '🛢'+user.endurance.to_s
    end.ljust(4, '-')
  end

  def user_link(user)
    "<a href='tg://user?id=#{user.telegram_id}'>#{user.game_name}</a>"
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map { |company_id, count| "#{SMILE[company_id]}#{count}" }.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map { |kill, count| "#{KILL[kill]}#{count}" }.join('|')
  end

  def icon_achivment(achivment, user)
    return achivment.icon if user.achivments.include?(achivment) ? achivment.icon
    achivment.public ? '❔' : ''
  end

  def description_achivment(achivment)
    str = "#{achivment.icon}#{achivment.title} "
    str << "- #{achivment.description} " if achivment.show?
    str << "#{achivment.percentage.round(2)}%"
  end

  def achivments_report(user)
    Achivment.all.each_with_object('') do |achivment, result|
      result << icon_achivment(achivment, user)
    end << "\n"
  end
end

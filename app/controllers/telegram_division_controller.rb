class TelegramWebhooksController < Telegram::Bot::UpdatesController
  before_action :set_user, only: [:me, :give, :message, :achivments]
  before_action :set_division, only: [:summary]

  def start(*)
    respond_with :message, text: t('.hi')
  end

  def help(*)
    respond_with :message, text: t('.hi')
  end

  def hashtags(*)
    respond_with :message, text: t('.hi')
  end

  def me(*)
    respond_with :message, text: render_to_string('user/show', @user), parse_mode: 'HTML' if @user
  end

  def achivements(*)
    respond_with :message, text: render_to_string('user/achivement', @user), parse_mode: 'HTML' if @user
  end

  def give(*)
    return unless @user
    @user.add_achivment(Achivment.first) if Digest::MD5.hexdigest(@user.game_name) == value[0]
  end 

  def summary(*)
    respond_with :message, text: render_to_string('division/summary', @division), parse_mode: 'HTML' if @division
  end

  def message(message)
  end

  private

  def set_user
    @user = User.find_by_telegram_id()
  end

  def set_division
    @division = Division.find_by_telegram_id()
  end
end

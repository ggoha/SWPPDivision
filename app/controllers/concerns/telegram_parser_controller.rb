class TelegramParserController < Telegram::Bot::UpdatesController
  include ReportParsed

  def start(*)
    respond_with :message, text: t('.content')
  end

  def channel_post(message)
    return unless from_swreport
    parse(message, message_type(message))
  end
end

require 'telegram/bot'

module Shumbrat
  class Bonifas
    attr_reader :token, :op_url

    def initialize
      @token = ENV.fetch('TELEGRAM_BOT_API_TOKEN', nil)
      @op_url = ENV.fetch('SHUMBRAT_OPENAPI_URL', nil)
    end

    def run
      Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
        bot.logger.info('Bot has been started')
        start_bot_time = Time.now.to_i

        bot.listen do |message|
          next if message.date < start_bot_time

          case message.text
          when '/start'
            text = "Hello, #{message.from.first_name}"
          when '/stop'
            text = "Bye, #{message.from.first_name}"
          when '/users'
            text = Shumbrat.users_data(params: {}).map do |u|
              [u[:id], u[:login]].join(': ')
            end.join("\n")
          when '/projects'
            text = Shumbrat.projects_data(params: {}).map do |p|
              [p[:id], p[:name]].join(': ')
            end.join("\n")
          when %r{/wps}
            _, project_id = message.text.split
            begin
              text = Shumbrat.wps_from_project_data(project_id:).map do |p|
                [p[:id], p[:subject]].join(': ')
              end.join("\n")
            rescue ClientError => e
              text = e.message
            end
          end

          bot.api.send_message(chat_id: message.chat.id, text: normalize_text(text))
        end
      end
    end

    def normalize_text(text)
      return 'Здесь ничего не нашлось (пустой массив)' if text.empty?

      text
    end
  end
end

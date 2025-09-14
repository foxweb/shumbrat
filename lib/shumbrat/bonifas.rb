require 'telegram/bot'

module Shumbrat
  class Bonifas
    attr_reader :token, :op_url

    def initialize
      @token = ENV.fetch('TELEGRAM_BOT_API_TOKEN', nil)
      @op_url = ENV.fetch('SHUMBRAT_OPENAPI_URL', nil)
    end

    def run # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      raise 'No token provided' unless token
      raise 'No OpenProject URL provided' unless op_url

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
            text = users_message
          when '/projects'
            text = projects_message
          when %r{/wps}
            begin
              _, project_id = message.text.split
              text = project_id ? wps_message(project_id) : 'Укажите ID проекта'
            rescue ClientError => e
              text = escaped_text(e.message)
            end
          else
            text = 'Неизвестная команда'
          end

          bot.api.send_message(chat_id: message.chat.id, text: normalize_text(text),
                               parse_mode: 'MarkdownV2')
        end
      end
    end

    def normalize_text(text)
      return escaped_text('Здесь ничего не нашлось (пустой массив)') if text.empty?

      text
    end

    def escaped_text(text) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return '' unless text

      text
        .gsub('_', '\\_')
        .gsub('*', '\\*')
        .gsub('[', '\\[')
        .gsub(']', '\\]')
        .gsub('(', '\\(')
        .gsub(')', '\\)')
        .gsub('~', '\\~')
        .gsub('`', '\\`')
        .gsub('>', '\\>')
        .gsub('#', '\\#')
        .gsub('+', '\\+')
        .gsub('-', '\\-')
        .gsub('=', '\\=')
        .gsub('|', '\\|')
        .gsub('{', '\\{')
        .gsub('}', '\\}')
        .gsub('.', '\\.')
        .gsub('!', '\\!')
    end

    def users_message
      Shumbrat.users_data(params: {}).map do |u|
        link = "[#{escaped_text(u[:name])}](#{user_url(u[:id])})"
        [u[:id], link].join(': ')
      end.join("\n")
    end

    def user_url(id)
      return unless id

      [ENV.fetch('SHUMBRAT_OPENAPI_URL', nil), 'users', id].join('/')
    end

    def projects_message
      Shumbrat.projects_data(params: {}).map do |p|
        link = "[#{escaped_text(p[:name])}](#{project_url(p[:identifier])})"
        [p[:id], link].join(': ')
      end.join("\n")
    end

    def project_url(identifier)
      return unless identifier

      [
        ENV.fetch('SHUMBRAT_OPENAPI_URL', nil),
        'projects',
        identifier,
        'work_packages'
      ].join('/')
    end

    def wps_message(project_id)
      return unless project_id

      Shumbrat.wps_from_project_data(project_id:).map do |wp|
        link = "[#{escaped_text(wp[:subject])}](#{wp_url(wp[:id])})"
        [wp[:id], link].join(': ')
      end.join("\n")
    end

    def wp_url(id)
      return unless id

      [ENV.fetch('SHUMBRAT_OPENAPI_URL', nil), 'wp', id, 'activity'].join('/')
    end
  end
end

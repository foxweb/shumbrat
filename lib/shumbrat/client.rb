require 'faraday'

module Shumbrat
  class Client
    NAMESPACE = 'api/v3'.freeze
    attr_reader :connection

    def initialize
      @connection = Client.make_connection(ENV.fetch('SHUMBRAT_OPENAPI_URL', nil))
    end

    def healthcheck
      request(:get, 'health_check')
    end

    def users(params:)
      get('users', params)
    end

    def projects(params:)
      get('projects', params)
    end

    def wps_from_project(project_id:)
      get("projects/#{project_id}/work_packages")
    end

  private
    def post_data(url, params = {})
      request(:post, [NAMESPACE, url].join('/'), params)
    end

    def get(url, params = {})
      request(:get, [NAMESPACE, url].join('/'), params)
    end

    def request(method, url, params = {})
      response = connection.public_send(method, url, params)

      if response.success?
        response.body
      else
        handle_error(response)
      end
    end

    def handle_error(response)
      raise(
        ClientError,
        # "Shumbrat responded with HTTP #{response.status}: #{response.body.ai}"
        response.body[:message]
      )
    end

    class << self
      def make_connection(url)
        Faraday.new(url:, ssl: { verify: false }) do |builder|
          builder.request :json
          builder.request :authorization, :basic, 'apikey', ENV.fetch('SHUMBRAT_OPENAPI_TOKEN', nil)
          builder.response :json, content_type:   'application/hal+json',
                                  parser_options: { symbolize_names: true }

          builder.adapter  Faraday.default_adapter
        end
      end
    end
  end
end

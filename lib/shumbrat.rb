require './config/dotenv'
require 'pry'
require 'awesome_print'
require './lib/shumbrat/bonifas'
require './lib/shumbrat/client'
require './lib/shumbrat/client_error'

module Shumbrat
  class << self
    def users_data(params:)
      client.users(params:)[:_embedded][:elements].map do |user|
        {
          id:     user[:id],
          login:  user[:login],
          email:  user[:email],
          admin:  user[:admin],
          status: user[:status],
          name:   user[:name],
          link:   user[:_links][:self][:href]
        }
      end
    end

    def projects_data(params:)
      client.projects(params:)[:_embedded][:elements].map do |project|
        {
          id:         project[:id],
          name:       project[:name],
          identifier: project[:identifier],
          link:       project[:_links][:self][:href]
        }
      end
    end

    def wps_from_project_data(project_id:)
      client.wps_from_project(project_id:)[:_embedded][:elements].map do |wp|
        {
          id:      wp[:id],
          subject: wp[:subject],
          link:    wp[:_links][:self][:href]
        }
      end
    end

    def healthcheck
      puts client.healthcheck
    end

  private

    def client
      @client ||= Client.new
    end
  end
end

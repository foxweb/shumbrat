require './config/dotenv'
require './config/oj'
require 'pry'
require 'awesome_print'
require './lib/shumbrat/client'
require './lib/shumbrat/client_error'

module Shumbrat
  class << self
    def client
      @client ||= Client.new
    end

    def users_data
      client.users[:_embedded][:elements].map do |user|
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

    def projects_data
      client.projects[:_embedded][:elements].map do |project|
        {
          id:   project[:id],
          name: project[:name],
          link: project[:_links][:self][:href]
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
  end
end

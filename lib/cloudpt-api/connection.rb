require "cloudpt-api/connection/requests"

module Cloudpt
  module API

    class Connection

      include Cloudpt::API::Connection::Requests

      attr_accessor :consumers
      attr_accessor :tokens

      def initialize(options = {})
        @options   = options
        @consumers = {}
        @tokens    = {}
        Cloudpt::API::Config.endpoints.each do |endpoint, url|
          @consumers[endpoint] = Cloudpt::API::OAuth.consumer(endpoint)
          @tokens[endpoint]    = Cloudpt::API::OAuth.access_token(@consumers[endpoint], options)
        end
      end

      def consumer(endpoint = :main)
        @consumers[endpoint]
      end

      def token(endpoint = :main)
        @tokens[endpoint]
      end

    end

  end
end

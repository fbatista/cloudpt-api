module Cloudpt
  module API

    module OAuth

      class << self

        def consumer(endpoint)
          if !Cloudpt::API::Config.app_key or !Cloudpt::API::Config.app_secret
            raise Cloudpt::API::Error::Config.new("app_key or app_secret not provided")
          end
          ::OAuth::Consumer.new(Cloudpt::API::Config.app_key, Cloudpt::API::Config.app_secret,
            :site => Cloudpt::API::Config.endpoints[endpoint],
            :request_token_path => Cloudpt::API::Config.prefix + "/oauth/request_token",
            :authorize_path     => Cloudpt::API::Config.prefix + "/oauth/authorize",
            :access_token_path  => Cloudpt::API::Config.prefix + "/oauth/access_token")
        end

        def access_token(consumer, options = {})
          ::OAuth::AccessToken.new(consumer, options[:token], options[:secret])
        end

      end

    end

  end
end


module Cloudpt
  module API

    class Tasks

      extend Rake::DSL if defined? Rake::DSL

      def self.install

        namespace :cloudpt do
          desc "Authorize wizard for Cloudpt API"
          task :authorize do
            require "cloudpt-api"
            require "cgi"
            print "Enter consumer key: "
            consumer_key = $stdin.gets.chomp
            print "Enter consumer secret: "
            consumer_secret = $stdin.gets.chomp

            Cloudpt::API::Config.app_key    = consumer_key
            Cloudpt::API::Config.app_secret = consumer_secret

            consumer = Cloudpt::API::OAuth.consumer(:authorize)
            request_token = consumer.get_request_token
            puts "\nGo to this url and click 'Authorize' to get the token:"
            puts request_token.authorize_url
            query  = request_token.authorize_url.split('?').last
            params = CGI.parse(query)
            token  = params['oauth_token'].first
            print "\nOnce you authorize the app on Cloudpt, press enter... "
            $stdin.gets.chomp

            access_token  = request_token.get_access_token(:oauth_verifier => token)

            puts "\nAuthorization complete!:\n\n"
            puts "  Cloudpt::API::Config.app_key    = '#{consumer.key}'"
            puts "  Cloudpt::API::Config.app_secret = '#{consumer.secret}'"
            puts "  client = Cloudpt::API::Client.new(:token  => '#{access_token.token}', :secret => '#{access_token.secret}')"
            puts "\n"
          end
        end

      end

    end

  end
end

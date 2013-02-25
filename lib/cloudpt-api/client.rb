require "cloudpt-api/client/raw"
require "cloudpt-api/client/files"

module Cloudpt
  module API

    class Client

      attr_accessor :raw, :connection

      def initialize(options = {})
        @connection = Cloudpt::API::Connection.new(:token  => options.delete(:token),
                                                   :secret => options.delete(:secret))
        @raw        = Cloudpt::API::Raw.new :connection => @connection
        @options    = options
      end

      include Cloudpt::API::Client::Files

      def find(filename)
        data = self.raw.metadata(:path => filename)
        data.delete('contents')
        Cloudpt::API::Object.convert(data, self)
      end

      def list(path = '')
        response = raw.list :path => path
      end

      def ls(path = '')
        Cloudpt::API::Dir.init({'path' => path}, self).ls
      end

      def account
        Cloudpt::API::Object.init(self.raw.account, self)
      end

      def mkdir(path)
        # Remove the characters not allowed by Cloudpt
        path = path.gsub(/[\\\:\?\*\<\>\"\|]+/, '')
        response = raw.create_folder :path => path
        Cloudpt::API::Dir.init(response, self)
      end

      def search(term, options = {})
        options[:path] ||= ''
        results = raw.search({ :query => term }.merge(options))
        Cloudpt::API::Object.convert(results, self)
      end

      def delta(cursor=nil)
        entries  = []
        has_more = true
        params   = cursor ? {:cursor => cursor} : {}
        while has_more
          response        = raw.delta(params)
          params[:cursor] = response['cursor']
          has_more        = response['has_more']
          entries.push     *response['entries']
        end

        files = entries.map do |entry|
          entry.last || {:is_deleted => true, :path => entry.first}
        end

        Delta.new(params[:cursor], Cloudpt::API::Object.convert(files, self))
      end

    end

  end
end

module Cloudpt
  module API

    class Raw

      attr_accessor :connection

      def initialize(options = {})
        @connection = options[:connection]
      end

      def self.add_method(method, action, options = {})
        # Add the default root bit, but allow it to be disabled by a config option
        root = options[:root] == false ? '' : "options[:root] ||= Cloudpt::API::Config.mode"
        self.class_eval <<-STR
          def #{options[:as] || action}(options = {})
            #{root}
            request(:#{options[:endpoint] || 'main'}, :#{method}, "#{action}", options)
          end
        STR
      end

      def request(endpoint, method, action, data = {})
        action.sub! ':root', data.delete(:root) if action.match ':root'
        action.sub! ':path', Cloudpt::API::Util.escape(data.delete(:path)) if action.match ':path'
        action = Cloudpt::API::Util.remove_double_slashes(action)
        connection.send(method, endpoint, action, data)
      end

      add_method :get,  "/Account/Info",           :as => 'account', :root => false

      add_method :get,  "/Metadata/:root/:path",   :as => 'metadata'
      add_method :post, "/Delta",                  :as => 'delta', :root => false
      add_method :get,  "/Revisions/:root/:path",  :as => 'revisions'
      add_method :post, "/Restore/:root/:path",    :as => 'restore'
      add_method :get,  "/Search/:root/:path",     :as => 'search'
      add_method :post, "/Shares/:root/:path",     :as => 'shares'
      add_method :post, "/Media/:root/:path",      :as => 'media'

      add_method :get_raw, "/Thumbnails/:root/:path", :as => 'thumbnails', :endpoint => :content

      add_method :post, "/Fileops/Copy",           :as => "copy"
      add_method :get,  "/CopyRef/:root/:path",    :as => 'copy_ref'
      add_method :post, "/Fileops/CreateFolder",   :as => "create_folder"
      add_method :post, "/Fileops/Delete",         :as => "delete"
      add_method :post, "/Fileops/Move",           :as => "move"
      add_method :get, "/List/:root/:path",       :as => "list"

    end

  end
end

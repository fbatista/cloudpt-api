module Cloudpt
  module API

    class Client

      module Files

        def download(path, options = {})
          root     = options.delete(:root) || Cloudpt::API::Config.mode
          path     = Cloudpt::API::Util.escape(path)
          url      = ["", "Files", root, path].compact.join('/')
          connection.get_raw(:content, url)
        end

        def upload(path, data, options = {})
          root     = options.delete(:root) || Cloudpt::API::Config.mode
          method   = options.delete(:method)
          query    = Cloudpt::API::Util.query(options)
          path     = Cloudpt::API::Util.escape(path)
          url      = ["", "Files", root, path].compact.join('/')
          if method == :post
            response = connection.post(:content, "#{url}?#{query}", data, {
              'Content-Type'   => "application/octet-stream",
              "Content-Length" => data.length.to_s
            })
          else
            response = connection.put(:content, "#{url}?#{query}", data, {
              'Content-Type'   => "application/octet-stream",
              "Content-Length" => data.length.to_s
            })
          end
          Cloudpt::API::File.init(response, self)
        end

        def copy_from_copy_ref(copy_ref, to, options = {})
          raw.copy({ 
            :from_copy_ref => copy_ref, 
            :to_path => to 
          }.merge(options))
        end

      end

    end

  end
end


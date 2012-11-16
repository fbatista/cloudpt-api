module Cloudpt
  module API

    class Dir < Cloudpt::API::Object

      include Cloudpt::API::Fileops

      def ls(path_to_list = '')
        data = client.raw.metadata :path => path + path_to_list
        if data['is_dir']
          Cloudpt::API::Object.convert(data.delete('contents') || [], client)
        else
          [Cloudpt::API::Object.convert(data, client)]
        end
      end

    end

  end
end

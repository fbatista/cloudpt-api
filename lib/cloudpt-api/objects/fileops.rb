module Cloudpt
  module API

    module Fileops

      def copy(to, options = {})
        response = client.raw.copy({ :from_path => "/#{self.path}", :to_path => "/#{Cloudpt::API::Util.strip_slash(to)}" }.merge(options))
        self.update response
      end

      def move(to, options = {})
        response = client.raw.move({ :from_path => "/#{self.path}", :to_path => "/#{Cloudpt::API::Util.strip_slash(to)}" }.merge(options))
        self.update response
      end

      def destroy(options = {})
        response = client.raw.delete({ :path => "/#{self.path}" }.merge(options))
        self.update response
      end

      def path
        Cloudpt::API::Util.strip_slash(self['path'])
      end

    end

  end
end

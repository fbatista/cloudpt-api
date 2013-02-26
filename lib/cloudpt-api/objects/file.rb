module Cloudpt
  module API

    class File < Cloudpt::API::Object

      include Cloudpt::API::Fileops

      def revisions(options = {})
        response = client.raw.revisions({ :path => self.path }.merge(options))
        Cloudpt::API::Object.convert(response, client)
      end

      def restore(rev, options = {})
        response = client.raw.restore({ :rev => rev, :path => self.path }.merge(options))
        self.update response
      end

      def share_url(options = {})
        response = client.raw.shares({ :path => self.path }.merge(options))
        Cloudpt::API::Object.init(response, client)
      end

      def direct_url(options = {})
        response = client.raw.media({ :path => self.path }.merge(options))
        Cloudpt::API::Object.init(response, client)
      end

      def thumbnail(options = {})
        client.raw.thumbnails({ :path => self.path }.merge(options))
      end
      
      def copy_ref(options = {})
        response = client.raw.copy_ref({ :path => self.path }.merge(options))
        Cloudpt::API::Object.init(response, client)
      end


      #alias_method :old_path, :path
      #def path
      #  if Cloudpt::API::Config.mode == 'sandbox'
      #    Cloudpt::API::Util.strip_slash(self['path'].sub(/^\/([^\/]+)?/, ''))
      #  else
      #    old_path
      #  end
      #end
      
      def download
        client.download(self.path)
      end

    end

  end
end

module Cloudpt
  module API

    class Error < Exception

      class ConnectionFailed < Exception; end
      class Config < Exception; end
      class Unauthorized < Exception; end
      class Forbidden < Exception; end
      class NotFound < Exception; end
      class Redirect < Exception; end
      class ServerError < Exception; end
    end

  end
end

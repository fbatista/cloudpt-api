require "oauth"
require "multi_json"
require "hashie"

module Cloudpt
  module API

  end
end

require "cloudpt-api/version"
require "cloudpt-api/util/config"
require "cloudpt-api/util/oauth"
require "cloudpt-api/util/error"
require "cloudpt-api/util/util"
require "cloudpt-api/objects/object"
require "cloudpt-api/objects/fileops"
require "cloudpt-api/objects/file"
require "cloudpt-api/objects/dir"
require "cloudpt-api/objects/delta"
require "cloudpt-api/connection"
require "cloudpt-api/client"

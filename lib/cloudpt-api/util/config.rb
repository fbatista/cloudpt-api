module Cloudpt
  module API

    module Config

      class << self
        attr_accessor :endpoints
        attr_accessor :prefix
        attr_accessor :app_key
        attr_accessor :app_secret
        attr_accessor :mode
      end

      self.endpoints = {
        :main      => "https://api.cloudpt.pt",
        :content   => "https://api-content.cloudpt.pt",
        :authorize => "https://cloudpt.pt"
      }
      self.prefix     = ""
      self.app_key    = nil
      self.app_secret = nil
      self.mode       = nil

    end

  end
end

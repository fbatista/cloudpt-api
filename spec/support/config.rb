require "yaml"

config = YAML.load_file "spec/connection.yml"

Cloudpt::API::Config.app_key    = config['app_key']
Cloudpt::API::Config.app_secret = config['app_secret']
Cloudpt::API::Config.mode       = config['mode']

Cloudpt::Spec.token  = config['token']
Cloudpt::Spec.secret = config['secret']

Cloudpt::Spec.namespace = Time.now.to_i
Cloudpt::Spec.instance  = Cloudpt::API::Client.new(:token  => Cloudpt::Spec.token,
                                                   :secret => Cloudpt::Spec.secret)
Cloudpt::Spec.test_dir = "test-#{Time.now.to_i}"

require "spec_helper"

describe Cloudpt::API::OAuth do

  describe ".consumer" do

    it "raises an error if config options are not provided" do
      Cloudpt::API::Config.stub!(:app_key).and_return(nil)
      lambda {
        Cloudpt::API::OAuth.consumer :main
      }.should raise_error(Cloudpt::API::Error::Config)
    end

  end

end


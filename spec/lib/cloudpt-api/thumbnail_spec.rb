require "spec_helper"
require "fileutils"

describe Cloudpt::API::File do

  before do
    @io       = StringIO.new
    @client   = Cloudpt::Spec.instance
    @dir      = @client.mkdir Cloudpt::Spec.test_dir
    @filename = "#{Cloudpt::Spec.test_dir}/spec-test-#{Time.now.to_i}.jpg"
    jpeg      = File.read("spec/fixtures/cloudpt.jpg")
    @file     = @client.upload @filename, jpeg
  end

  describe "#thumbnail" do

    it "downloads a thumbnail" do
      sleep(2)
      result = @file.thumbnail

      @io << result
      @io.rewind

      jpeg = JPEG.new(@io)
      jpeg.height.should == 32
      jpeg.width.should == 32
    end

  end

end

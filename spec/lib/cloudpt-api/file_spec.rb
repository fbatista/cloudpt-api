require "spec_helper"

describe Cloudpt::API::File do

  before do
    @client = Cloudpt::Spec.instance
    @dirname = "#{Cloudpt::Spec.test_dir}"
    @dir = @client.mkdir @dirname
    @filename = "#{Cloudpt::Spec.test_dir}/spec-test-#{Time.now.to_i}.txt"
    @file = @client.upload @filename, "spec file"
  end

  after do
    @dir.destroy
  end

  describe "#copy" do

    it "copies the file properly" do
      new_filename = @filename + ".copied"
      @file.copy new_filename
      @file.path.should == new_filename
    end

  end
  
  describe "#move" do

    it "moves the file properly" do
      new_filename = @filename + ".copied"
      @file.move new_filename
      @file.path.should == new_filename
    end

  end

  describe "#destroy" do

    it "destroys the file properly" do
      @file.destroy
      @file.is_deleted.should == true
    end

  end

  describe "#revisions" do

    it "retrieves all revisions as an Array of File objects" do
      sleep(2)
      @client.upload @file.path, "Updated content", {'overwrite' => true, :method => :post, 'parent_rev' => @file.rev}
      #FAIL AT SERVER ?
      revisions = @file.revisions
      revisions.size.should == 2
      revisions.collect { |f| f.class }.should == [Cloudpt::API::File, Cloudpt::API::File]
    end

  end

  describe "#restore" do

    it "restores the file to a specific revision" do
      old_rev = @file.rev

      @client.upload @file.path, "Updated content", {'overwrite' => true, :method => :post, 'parent_rev' => old_rev}

      file = @filename.split('/').last
      
      sleep(2)
      found = @client.find(@file.path)

      found.rev.should_not == old_rev

      newer_rev = found.rev

      @file.restore(old_rev)

      sleep(2)
      found = @client.find(@file.path)

      found.rev.should_not == old_rev
      found.rev.should_not == newer_rev

    end

  end

  describe "#share_url" do

    it "returns an Url object" do

      result = @file.share_url
      result.should be_an_instance_of(Cloudpt::API::Object)
      result.should have_key 'expires'
      result.should have_key 'url'
      result.should have_key 'link_shareid'
    end

  end

  describe "#copy_ref" do
    
    it "returns a copy_ref object" do
      sleep(2)
      result = @file.copy_ref
      result.should be_an_instance_of(Cloudpt::API::Object)
      result.should have_key 'copy_ref'
      result.should have_key 'expires'
    end
    
  end

  describe "#direct_url" do

    it "returns an Url object" do
      sleep(2)
      result = @file.direct_url
      result.should be_an_instance_of(Cloudpt::API::Object)
      result.should have_key 'url'
      result.should have_key 'expires'
    end

  end

  describe "#download" do

    it "should download the file" do
      @file.download.should == 'spec file'
    end

  end

end

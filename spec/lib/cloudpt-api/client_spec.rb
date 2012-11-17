# encoding: utf-8
require "spec_helper"

describe Cloudpt::API::Client do

  before do
    # pending
    @client = Cloudpt::Spec.instance
  end

  describe "#initialize" do

    it "has a handle to the connection" do
      @client.connection.should be_an_instance_of(Cloudpt::API::Connection)
    end

  end

  describe "#account" do

    it "retrieves the account object" do
      response = @client.account
      response.should be_an_instance_of(Cloudpt::API::Object)
    end

  end

  describe "#find" do

    before do
      @filename = "#{Cloudpt::Spec.test_dir}/spec-find-file-test-#{Time.now.to_i}.txt"
      @file = @client.upload @filename, "spec file"

      @dirname = "#{Cloudpt::Spec.test_dir}/spec-find-dir-test-#{Time.now.to_i}"
      @dir = @client.mkdir @dirname
    end

    it "returns a single file" do
      response = @client.find(@filename)
      response.path.should == @file.path
      response.should be_an_instance_of(Cloudpt::API::File)
    end

    it "returns a single directory" do
      response = @client.find(@dirname)
      response.path.should == @dir.path
      response.should be_an_instance_of(Cloudpt::API::Dir)
    end

  end

  describe "#ls" do

    it "returns an array of files and dirs" do
      result = @client.ls
      result.should be_an_instance_of(Array)
    end

    it "returns a single item array of if we ls a file" do
      result     = @client.ls(Cloudpt::Spec.test_dir)
      first_file = result.detect { |f| f.class == Cloudpt::API::File }
      result     = @client.ls first_file.path
      result.should be_an_instance_of(Array)
    end

  end

  describe "#mkdir" do

    it "returns an array of files and dirs" do
      dirname  = "#{Cloudpt::Spec.test_dir}/test-dir-#{Cloudpt::Spec.namespace}"
      response = @client.mkdir dirname
      response.path.should == dirname
      response.should be_an_instance_of(Cloudpt::API::Dir)
    end

    it "creates dirs with tricky characters" do
      dirname  = "#{Cloudpt::Spec.test_dir}/test-dir |!@\#$%^&*{b}[].;'.,<>?: #{Cloudpt::Spec.namespace}"
      response = @client.mkdir dirname
      response.path.should == dirname.gsub(/[\\\:\?\*\<\>\"\|]+/, '')
      response.should be_an_instance_of(Cloudpt::API::Dir)
    end

    it "creates dirs with utf8 characters" do
      dirname  = "#{Cloudpt::Spec.test_dir}/test-dir łółą #{Cloudpt::Spec.namespace}"
      response = @client.mkdir dirname
      response.path.should == dirname
      response.should be_an_instance_of(Cloudpt::API::Dir)
    end

  end

  describe "#upload" do

    it "puts the file in Cloudpt" do
      filename = "#{Cloudpt::Spec.test_dir}/test-#{Cloudpt::Spec.namespace}.txt"
      response = @client.upload filename, "Some file"
      response.path.should == filename
      response.bytes.should == 9
    end

    it "uploads the file with tricky characters" do
      filename = "#{Cloudpt::Spec.test_dir}/test ,|!@\#$%^&*{b}[].;'.,<>?:-#{Cloudpt::Spec.namespace}.txt"
      response = @client.upload filename, "Some file"
      response.path.should == filename
      response.bytes.should == 9
    end

    it "uploads the file with utf8" do
      filename = "#{Cloudpt::Spec.test_dir}/test łołąó-#{Cloudpt::Spec.namespace}.txt"
      response = @client.upload filename, "Some file"
      response.path.should == filename
      response.bytes.should == 9
    end
  end

  describe "#search" do

    let(:term) { "searchable-test-#{Cloudpt::Spec.namespace}" }

    before do
      filename = "#{Cloudpt::Spec.test_dir}/searchable-test-#{Cloudpt::Spec.namespace}.txt"
      @client.upload filename, "Some file"
    end

    after do
      @response.size.should == 1
      @response.first.class.should == Cloudpt::API::File
    end

    it "finds a file" do
      @response = @client.search term, :path => "#{Cloudpt::Spec.test_dir}"
    end

    it "works if leading slash is present in path" do
      @response = @client.search term, :path => "/#{Cloudpt::Spec.test_dir}"
    end

  end

  describe "#copy_from_copy_ref" do

    it "copies a file from a copy_ref" do
      filename = "test/searchable-test-#{Cloudpt::Spec.namespace}.txt"
      @client.upload filename, "Some file"
      response = @client.search "searchable-test-#{Cloudpt::Spec.namespace}", :path => 'test'      
      ref = response.first.copy_ref['copy_ref']
      @client.copy_from_copy_ref ref, "#{filename}.copied"
      response = @client.search "searchable-test-#{Cloudpt::Spec.namespace}.txt.copied", :path => 'test'   
      response.size.should == 1
      response.first.class.should == Cloudpt::API::File
    end

  end

  describe "#download" do

    it "downloads a file from Cloudpt" do
      @client.upload "#{Cloudpt::Spec.test_dir}/test.txt", "Some file"
      file = @client.download "#{Cloudpt::Spec.test_dir}/test.txt"
      file.should == "Some file"
    end

    it "raises a 404 when a file is not found in Cloudpt" do
      lambda {
        @client.download "#{Cloudpt::Spec.test_dir}/no.txt"
      }.should raise_error(Cloudpt::API::Error::NotFound)
    end

  end

  describe "#delta" do
    it "returns a cursor and list of files" do
      filename = "#{Cloudpt::Spec.test_dir}/delta-test-#{Cloudpt::Spec.namespace}.txt"
      @client.upload filename, 'Some file'
      response = @client.delta
      cursor, files = response.cursor, response.entries
      cursor.should be_an_instance_of(String)
      files.should be_an_instance_of(Array)
      files.last.should be_an_instance_of(Cloudpt::API::File)
    end

    it "returns the files that have changed since the cursor was made" do
      filename = "#{Cloudpt::Spec.test_dir}/delta-test-#{Cloudpt::Spec.namespace}.txt"
      delete_filename = "#{Cloudpt::Spec.test_dir}/delta-test-delete-#{Cloudpt::Spec.namespace}.txt"
      @client.upload delete_filename, 'Some file'
      response = @client.delta
      cursor, files = response.cursor, response.entries
      files.last.path.should == delete_filename
      files.last.destroy
      @client.upload filename, 'Another file'
      response = @client.delta(cursor)
      cursor, files = response.cursor, response.entries
      files.length.should == 2
      files.first.is_deleted.should == true
      files.first.path.should == delete_filename
      files.last.path.should == filename
    end
  end

end

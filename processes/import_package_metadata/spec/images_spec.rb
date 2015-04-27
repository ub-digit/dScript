require_relative '../image.rb'
#require 'webmock'
require 'webmock/rspec'
require_relative '../../../helpers/dscript_helper.rb'
require_relative '../../../helpers/dfile_api.rb'
require_relative '../../../helpers/dflow_api.rb'
require_relative '../../../config.rb'

describe ImportPackageMetadata::Images do
  before :all do
    @sh = DScript::ScriptHelper.new
    @dflow_api = DScript::DFlowAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api = DScript::DFileAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api_key = "test_key"
  end

  describe "fetch_page_count" do

    context "for an existing job" do
      it "should set page_count accordingly" do
        stub_request(:get, "http://localhost:3001/download_file?api_key=test_key&source_file=PACKAGING:/1/page_count/1.txt").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "10", :headers => {})

        images = ImportPackageMetadata::Images.new(dfile_api: @dfile_api, job: {'id' => 1})
        images.fetch_page_count

        expect(images.page_count).to eq 10
      end
    end
  end

  describe "fetch_images" do
    context "for 10 images" do
      it "should create 10 image objects" do
        images = ImportPackageMetadata::Images.new(dfile_api: @dfile_api, job: {'id' => 1})
        images.page_count = 10
        images.fetch_images
        expect(images.images.count).to eq 10
      end
    end
  end

    
end
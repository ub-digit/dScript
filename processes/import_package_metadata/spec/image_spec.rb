require_relative '../image.rb'
require 'webmock/rspec'
require_relative '../../../helpers/dscript_helper.rb'
require_relative '../../../helpers/dfile_api.rb'
require_relative '../../../helpers/dflow_api.rb'
require_relative '../../../config.rb'

describe ImportPackageMetadata::Image do
  before :all do
    @sh = DScript::ScriptHelper.new
    @dflow_api = DScript::DFlowAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api = DScript::DFileAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api_key = "test_key"
  end

  describe "map_physical" do

    context "a number that is not mapped" do
      it "should raise StandardError" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 1)
        expect{image.map_physical(physical_numeric: 0)}.to raise_error StandardError
      end
    end

    context "a number that is mapped" do
      it "should not raise StandardError" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 1)
        expect{image.map_physical(physical_numeric: 1)}.not_to raise_error
      end
    end

    context "The number for cover for image num 1" do
      it "should return text FrontCoverOutside" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 1)
        expect(image.map_physical(physical_numeric: 4)).to eq 'FrontCoverOutside'
      end
    end

    context "The number for cover for image num 2" do
      it "should return text FrontCoverInside" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 2)
        expect(image.map_physical(physical_numeric: 4)).to eq 'FrontCoverInside'
      end
    end

    context "The number for cover for image num 3" do
      it "should raise error" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 3)
        expect{image.map_physical(physical_numeric: 4)}.to raise_error StandardError
      end
    end

    context "The number for cover for second to last image" do
      it "should return text BackCoverInside" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 9)
        expect(image.map_physical(physical_numeric: 4)).to eq 'BackCoverInside'
      end
    end

    context "The number for cover for last image" do
      it "should return text BackCoverOutside" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 10)
        expect(image.map_physical(physical_numeric: 4)).to eq 'BackCoverOutside'
      end
    end

    context "The number for leftPage" do
      it "should return text LeftPage" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 2)
        expect(image.map_physical(physical_numeric: 1)).to eq 'LeftPage'
      end
    end
  end

  describe "map_logical" do

    context "for an invalid mapping number" do
      it "should return string 'Undefined'" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 2)
        expect(image.map_logical(logical_numeric: 0)).to eq 'Undefined'
      end
    end

    context "for a valid mapping number" do
      it "should return corresponding string" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: nil, image_count: 10, image_num: 2)
        expect(image.map_logical(logical_numeric: 4)).to eq 'TitlePage'
      end
    end
  end

  describe "validate_group_name" do
    
    context "for a nonexisting group_name" do
      it "should raise exception" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: [], image_count: 10, image_num: 3)
        expect{image.validate_group_name(group_name: "test")}.to raise_error StandardError
      end
    end

    context "for an existing group_name" do
      it "should return true" do
        image = ImportPackageMetadata::Image.new(dfile_api: nil, job_id: 1, group_names: ["groupName1", "groupName2"], image_count: 10, image_num: 3)
        expect(image.validate_group_name(group_name: "groupName2")).to be_truthy
      end
    end
  end

  describe "fetch_metadata" do

    context "for an image with type LeftPage and content TitlePage" do
      it "should set physical to 'LeftPage'" do

        stub_request(:get, 'http://localhost:3001'+'/download_file')
        .with(query: {source_file: "PACKAGING:/1/page_metadata/0003.xml", api_key: @api_key})
        .to_return(:body => File.new('processes/import_package_metadata/spec/stubs/0003.xml'), :status => 200)

        image = ImportPackageMetadata::Image.new(dfile_api: @dfile_api, job_id: 1, group_names: [], image_count: 10, image_num: 3)

        image.fetch_metadata

        expect(image.physical).to eq 'LeftPage'
      end
    end
  end
end
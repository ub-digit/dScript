require_relative '../mets'
require_relative '../config'
require_relative '../../../helpers/dscript_helper.rb'
require_relative '../../../helpers/dfile_api.rb'
require_relative '../../../helpers/dflow_api.rb'
require_relative '../../../config.rb'

describe CreateMETSPackage::METS do
  before :all do
    @sh = DScript::ScriptHelper.new
    @dflow_api = DScript::DFlowAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api = DScript::DFileAPI.new(@sh, "PACKAGE_METADATA_IMPORT")
    @dfile_api_key = "test_key"

    @job = JSON.parse(File.new('processes/create_mets_package/spec/fixtures/1001006.json', 'r:utf-8').read)['job']
    @mets = CreateMETSPackage::METS.new(dfile_api: @dfile_api, job: @job)
    pp DateTime.parse(@job['updated_at']).strftime("%FT%T")
    puts @mets.mets_xml
  end

  describe "checksum_file" do
    it "should do something" do
    end
  end

  describe "mets sections" do
    context "head" do
      it "should check for relevant information in header" do
        expect(@mets.head).to include("mets:metsHdr")
        expect(@mets.head).to include(CreateMETSPackage::CREATOR[:name])
        expect(@mets.head).to match(CreateMETSPackage::CREATOR[:sigel])
        expect(@mets.head).to match(CreateMETSPackage::ARCHIVIST[:name])
        expect(@mets.head).to match(CreateMETSPackage::ARCHIVIST[:sigel])
      end
    end

    context "administrative" do
      it "should check for relevant information in administrative" do
        expect(@mets.administrative).to include("mets:amdSec")
        expect(@mets.administrative).to include(CreateMETSPackage::COPYRIGHT_STATUS[true])
        expect(@mets.administrative).to match(CreateMETSPackage::PUBLICATION_STATUS[true])
      end
    end

    context "bibliographic" do
      it "should check for relevant information in bibliographic" do
        expect(@mets.bibliographic).to include("mets:dmdSec")
        expect(@mets.bibliographic).to include("2015-04-22T15:19:33")
        expect(@mets.bibliographic).to include("MODS")
      end
    end

  end
end

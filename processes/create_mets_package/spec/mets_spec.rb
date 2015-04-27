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
    @job = {
      'title' => "Test", 
      'author' => "Foo",
      'copyright' => true
    }
    @mets = CreateMETSPackage::METS.new(@job)
  end

  describe "checksum_file" do
    it "should do something" do
    end
  end

  describe "mets sections" do
    context "head" do
      it "should check for relevant information in header" do
        expect(@mets.head).to match("mets:metsHdr")
        expect(@mets.head).to match(CreateMETSPackage::CREATOR[:name])
        expect(@mets.head).to match(CreateMETSPackage::CREATOR[:sigel])
        expect(@mets.head).to match(CreateMETSPackage::ARCHIVIST[:name])
        expect(@mets.head).to match(CreateMETSPackage::ARCHIVIST[:sigel])
      end
    end

    context "administrative" do
      it "should check for relevant information in administrative" do
        expect(@mets.administrative).to match("mets:amdSec")
        expect(@mets.administrative).to match(CreateMETSPackage::COPYRIGHT_STATUS[true])
        expect(@mets.administrative).to match(CreateMETSPackage::PUBLICATION_STATUS[true])
      end
    end
  end
end

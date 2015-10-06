module CreateMETSPackage
  class DublinCore
    XML_SCHEMA="http://www.ub.gu.se/xml-schemas/simple-dc/v1/gub-simple-dc-20150812.xsd"
    attr_reader :mets_data
    TYPE_OF_RECORD = {
      "as" => "Serial",
      "am" => "Monograph",
      "tm" => "Manuscript"
    }

    # mets_data is global mets_data from CreateMETSPackage::METS
    def initialize(job, mets_data)
      @job = job
      @mets_data = mets_data
    end

    # Return source XML data, in this case just the data from the source API
    def xml_data
      @xml = @job['xml']
      @xml 
      @xml.gsub!(/<\?xml version="1.0"\?>/,'')

      return @xml
    end

    # Type for dublin_core is "DC"
    def xml_type
      "DC"
    end

    # Text representation of Type of Record, or code if not available. Used in output METS XML
    def type_of_record
      tor = @job['metadata']['type_of_record']
      TYPE_OF_RECORD[tor] || tor
    end

    # Manuscripts have image groups.
    # Wrapper for all image groups
    def extra_dmdsecs
      ""
    end

    def dmdid_attribute(groupname)
      ""
    end

  end
end

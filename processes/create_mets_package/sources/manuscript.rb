module CreateMETSPackage
  class Manuscript
    XML_SCHEMA="http://www.ub.gu.se/handskriftsdatabasen/api/schema.xsd"
    attr_reader :mets_data

    # mets_data is global mets_data from CreateMETSPackage::METS
    def initialize(job, mets_data)
      @job = job
      @mets_data = mets_data
    end

    # Return source XML data, in this case just the data from the source API
    def xml_data
      xml = @job['xml']
      xml.gsub!(/<\?xml version="1.0" encoding="utf-8"\?>/,'')
      "<gubs>#{xml}</gubs>"
    end

    # Type for manuscripts is "OTHER"
    def xml_type
      "OTHER"
    end

    # We have no readable translations for manuscript types, so just return whatever code we
    # have available
    def type_of_record
      @job['metadata']['type_of_record']
    end

    # Manuscripts have image groups.
    # Wrapper for all image groups
    def extra_dmdsecs
      creation_date = mets_data[:created_at]
      doc = Nokogiri::XML(@job['xml'])
      doc.search("/manuscript/document/data/imagedata").map do |imagedata|
        imagedata_id = imagedata.attr('hd-id').to_i
        extra_dmdsec("image_#{imagedata_id}", creation_date) { imagedata.to_xml }
      end.join("\n")
    end
    
    # Manuscript image group information
    #  Single entry for image group information
    def extra_dmdsec(dmdid, imagedata_xml)
      %Q(<mets:dmdSec ID="#{dmdid}" CREATED="#{mets_data[:created_at]}">
        <mets:mdWrap MDTYPE="#{xml_type}">
         <mets:xmlData>
          <pagegroup xsi:noNamespaceSchemaLocation="http://www.ub.gu.se/handskriftsdatabasen/api/imagedata.xsd">
           #{imagedata_xml}
          </pagegroup>
         </mets:xmlData>
        </mets:mdWrap>
       </mets:dmdSec>)
    end

    # Manuscript image group ID attribute
    #  We need to reference the above dmdSec, this is that reference id
    def dmdid_attribute(group_name)
      " DMDID=\"image_#{group_name}\""
    end
  end
end

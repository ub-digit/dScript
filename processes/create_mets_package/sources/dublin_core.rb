module CreateMETSPackage
  class DublinCore
    XML_SCHEMA="http://www.ub.gu.se/xml-schemas/simple-dc/v1/gub-simple-dc-20150812.xsd"
    attr_reader :mets_data

    # mets_data is global mets_data from CreateMETSPackage::METS
    def initialize(job, mets_data, source)
      @job = job
      @mets_data = mets_data
      @source
    end

    # Return source XML data, in this case just the data from the source API
    def xml_data
      @xml = @job['xml']
      2.times { clean_xml }
      @xml.gsub!(/<\?xml version="1.0" encoding="utf-8"\?>/,'')
      #return "<gubs>#{@xml}</gubs>"
    end

    # Type for manuscripts is "OTHER"
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
      doc = Nokogiri::XML(@job['xml'])
      doc.search("/manuscript/#{@source}/data/imagedata").map do |imagedata|
        imagedata_id = imagedata.attr('hd-id').to_i
        extra_dmdsec("image_#{imagedata_id}", imagedata.to_xml)
      end.join("\n")
    end

    def clean_xml
      doc = Nokogiri::XML(@xml, &:noblanks)
      clean_xml_traverse(doc)
      @xml = doc.to_xml(encoding:'utf-8')
    end

    def clean_xml_traverse(docroot)
      docroot.children.each do |element|
        if element.is_a?(Nokogiri::XML::Element)
          if element.children.nil? || element.children.empty?
            element.remove
          else
            clean_xml_traverse(element)
          end
        end
        if element.is_a?(Nokogiri::XML::Text)
          element.content = element.text.gsub(/^\s*/,'').gsub(/\s*$/,'')
        end
      end
    end
  end
end

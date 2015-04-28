module CreateMETSPackage
  class Libris
    TYPE_OF_RECORD = {
      "as" => "Serial",
      "am" => "Monograph",
      "tm" => "Monograph"
    }
    attr_reader :mets_data

    # mets_data is global mets_data from CreateMETSPackage::METS
    def initialize(job, mets_data)
      @job = job
      @mets_data = mets_data
    end

    # Return source XML data, transformed according to ALVIN specifications
    def xml_data
      "<mods>#{alvin_mods}</mods>"
    end

    # ALVIN specifies MODS as XML format
    def xml_type
      "MODS"
    end

    # Serials have different handling of metadata
    def is_serial?
      @job['metadata']['type_of_record'] == "as"
    end

    # Text representation of Type of Record, or code if not available. Used in output METS XML
    def type_of_record
      tor = @job['metadata']['type_of_record']
      TYPE_OF_RECORD[tor] || tor
    end

    # Libris does not use image groups, so this returns a simple empty string
    def extra_dmdsecs
      ""
    end

    # Libris does not use image groups, so this returns a simple empty string
    def dmdid_attribute
      ""
    end

    # XSLT template for transforming Libris MARCXML to ALVIN-MODS
    def alvin_xslt
      Nokogiri::XSLT(File.open("assets/LibrisToAlvin.xsl", "rb"))
    end

    # Use above template to do transformation
    # if job is a serial, append the metadata relevant for serials
    def alvin_mods
      alvin_xml = alvin_xslt.transform(Nokogiri::XML(@job['xml'])).search("mods").first
      is_serial? ? alvin_append_serial(alvin_xml).inner_html : alvin_xml.inner_html
    end

    # Compute an ALVIN compatible addon with extra metadata for serials
    def alvin_append_serial(a_mods)
      a_part = Nokogiri::XML::Node.new('part', a_mods)
      ordinals.each_with_index do |ordinal,i|
        a_detail = Nokogiri::XML::Node.new('detail', a_part)
        a_detail.set_attribute('type', "ordinal_#{i+1}")
        a_number = Nokogiri::XML::Node.new('number', a_detail)
        a_number.inner_html = ordinal[1].to_s
        a_detail.add_child(a_number)
        a_caption = Nokogiri::XML::Node.new('caption', a_detail)
        a_caption.inner_html = ordinal[0].to_s
        a_detail.add_child(a_caption)
        a_part.add_child(a_detail)
      end
      chronologicals.each_with_index do |chronological,i|
        a_detail = Nokogiri::XML::Node.new('detail', a_part)
        a_detail.set_attribute('type', "chronological_#{i+1}")
        a_number = Nokogiri::XML::Node.new('number', a_detail)
        a_number.inner_html = chronological[1].to_s
        a_detail.add_child(a_number)
        a_caption = Nokogiri::XML::Node.new('caption', a_detail)
        a_caption.inner_html = chronological[0].to_s
        a_detail.add_child(a_caption)
        a_part.add_child(a_detail)
      end
      a_mods.add_child(a_part)
      a_mods
    end

    def ordinals
      ordinal_data = []
      ordinal_data << seq_metadata_num("ordinal", 1) if seq_metadata_num("ordinal", 1)
      ordinal_data << seq_metadata_num("ordinal", 2) if seq_metadata_num("ordinal", 2)
      ordinal_data << seq_metadata_num("ordinal", 3) if seq_metadata_num("ordinal", 3)
      ordinal_data
    end

    def chronologicals
      chron_data = []
      chron_data << seq_metadata_num("chron", 1) if seq_metadata_num("chron", 1)
      chron_data << seq_metadata_num("chron", 2) if seq_metadata_num("chron", 2)
      chron_data << seq_metadata_num("chron", 3) if seq_metadata_num("chron", 3)
      chron_data
    end

    # Returns an ordinal array for given key
    def seq_metadata_num(name, num)
      key = metadata_value("#{name}_#{num}_key")
      value = metadata_value("#{name}_#{num}_value")
      return nil if key.blank? || value.blank?
      [key, value]
    end
  end
end

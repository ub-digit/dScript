module GupeaPackage

  class Package
    require 'nokogiri'
    attr_accessor :job, :xml

    def initialize(job, dfile_api, collection_id)
      @job = job
      @dfile_api = dfile_api
      @collection_id = collection_id #GUPEA collection id
    end

    def ordinals
      ordinals_string = ""
      if @job['metadata']['ordinal_1_key'] && @job['metadata']['ordinal_1_value']
        ordinals_string = @job['metadata']['ordinal_1_key'] + ' ' + @job['metadata']['ordinal_1_value']
      end

     if @job['metadata']['ordinal_2_key'] && @job['metadata']['ordinal_2_value']
        ordinals_string += ', ' + @job['metadata']['ordinal_2_key'] + ' ' + @job['metadata']['ordinal_2_value']
      end

     if @job['metadata']['ordinal_3_key'] && @job['metadata']['ordinal_3_value']
        ordinals_string += ', ' + @job['metadata']['ordinal_3_key'] + ' ' + @job['metadata']['ordinal_3_value']
      end

      ordinals_string
    end

    def chronologicals
      chronologicals_string = ""

      if @job['metadata']['chron_1_key'] && @job['metadata']['chron_1_value']
        chronologicals_string = @job['metadata']['chron_1_key'] + ' ' + @job['metadata']['chron_1_value']
      end

      if @job['metadata']['chron_2_key'] && @job['metadata']['chron_2_value']
        chronologicals_string += ', ' + @job['metadata']['chron_2_key'] + ' ' + @job['metadata']['chron_2_value']
      end

      if @job['metadata']['chron_3_key'] && @job['metadata']['chron_3_value']
        chronologicals_string += ', ' + @job['metadata']['chron_3_key'] + ' ' + @job['metadata']['chron_3_value']
      end

      chronologicals_string
    end

    def chronologicals_year
      if @job['metadata'].has_key?('chron_1_value')
        return @job['metadata']['chron_1_value'].to_i
      else
        return 0
      end
    end

    def create_xml

      xml = Nokogiri::XML('<?xml version = "1.0" encoding = "UTF-8" standalone ="no"?>')
      #puts Nokogiri::XML::Builder.with(xml) { |x| x.awesome }.to_xml
      builder = Nokogiri::XML::Builder.with(xml) do |xml|
        xml.dublin_core(:schema => "dc") {
          xml.dcvalue(:element => "title", :qualifier => "none") {
            xml.text "#{@job['title']} (#{ordinals})"
          }
          xml.dcvalue(:element => "contributor", :qualifier => "author") {
            xml.text @job['author']
          }
          xml.dcvalue(:element => "date", :qualifier => "issued") {
            xml.text chronologicals_year
          }
          xml.dcvalue(:element => "language", :qualifier => "iso") {
            xml.text "swe"
          }
          xml.dcvalue(:element => "type", :qualifier => "marc") {
            xml.text @job['metadata']['type_of_record']
          }
          xml.dcvalue(:element => "identifier", :qualifier => "librisid") {
            xml.text @job['catalog_id']
          }
          xml.dcvalue(:element => "identifier", :qualifier => "citation") {
            xml.text "#{ordinals} - #{chronologicals}"
          }
        }
      end
      @xml = builder.to_xml
    end

    # Creates package folder for delivery
    def create_folder
      if !@dfile_api.create_file(source: 'GUPEA', filename: "#{@job['id']}/collection", content: @collection_id)
        raise StandardError
      end

      if !@dfile_api.copy_file(from_source: 'STORE', from_file: "#{package_name}/pdf/#{package_name}.pdf", to_source: 'GUPEA', to_file: "#{@job['id']}/#{@job['id']}.pdf")
        raise StandardError
      end
    end

    def package_name
      return sprintf('GUB%07d', @job['id'])
    end
  end
end

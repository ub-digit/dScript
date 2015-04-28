require_relative 'sources/libris'
require_relative 'sources/manuscript'

module CreateMETSPackage

  # Describing one file, used for handling locations, checksums, renaming
  class FileObject
    def initialize(dfile_api, job_id, path, name, size)
      @dfile_api = dfile_api
      @job_id = job_id
      @path = path
      @name = name
      @size = size
      set_full_path
      @extension = name.gsub(/^.*\.([^\.]+)$/,'\1')
      @number = name.gsub(/^(\d+)\..*$/,'\1')
      @checksum = @dfile_api.checksum("PACKAGING", @full_path)
    end

    # Setting full path definition. Used both in initialize and renameing
    def set_full_path
      @full_path = "#{@job_id}/#{@path}/#{@name}"
    end

    # Rename single file from <JOBID>.xxx to GUB00<JOBID>.xxx
    # and recompute full path
    def rename_to_gub
      gubname = sprintf("GUB%07d.%s", @job_id, @extension)
      @dfile_api.rename_file("PACKAGING", @full_path, "#{@job_id}/#{@path}/#{gubname}")
      @name = gubname
      set_full_path
    end
  end
  
  # Describing a file group containing multiple or single file(s)
  # Keeps track of file type (extension), directory name within job,
  # and whether or not there should be multiple or single file entries
  class FileGroup
    def initialize(dfile_api, job_id, name, mimetype, extension, single = false)
      @dfile_api = dfile_api
      @name = name
      @mimetype = mimetype
      @extension = extension
      @single = single
      @files = []
      add_files
    end

    # Keep track of all relevant files in the directory
    def add_files
      @dfile_api.list_files("PACKAGING", "#{job_id}/#{@name}", @extension).each do |file|
        @files << FileObject.new(@dfile_api, job_id, @name, file['name'], file['size'])
      end
      if single? && !@files.empty?
        @files.first.rename_to_gub
      end
    end

    # Only a single file should be kept in this group
    def single?
      @single
    end
  end

  # Setup all necessary parts for creating METS XML
  class METS
    def initialize(dfile_api, job)
      @dfile_api = dfile_api
      @job = job

      case @job['source']
      when 'libris'
        @source = Libris.new(@job, mets_data)
      when 'dc'
        @source = nil
      when 'document'
        @source = Manuscript.new(@job, mets_data)
      when 'letter'
        @source = Manuscript.new(@job, mets_data)
      end

      @file_groups = []
      @file_groups << FileGroup.new(@dfile_api, @job['id'], "master", "image/tiff", "tif")
      @file_groups << FileGroup.new(@dfile_api, @job['id'], "web", "image/jpeg", "jpg")
      @file_groups << FileGroup.new(@dfile_api, @job['id'], "alto", "text/xml", "xml")
      @file_groups << FileGroup.new(@dfile_api, @job['id'], "pdf", "text/pdf", "pdf", true)
    end

    # Collect global data used by METS production in various places
    def mets_data
      {
        id: sprintf("GUB%07d", @job['id'].to_i),
        created_at: @job['created_at'].strftime("%FT%T"),
        updated_at: @job['updated_at'].strftime("%FT%T"),
        creator_sigel: CreateMETSPackage::CREATOR[:sigel],
        creator_name: CreateMETSPackage::CREATOR[:name],
        archivist_sigel: CreateMETSPackage::ARCHIVIST[:sigel],
        archivist_name: CreateMETSPackage::ARCHIVIST[:name],
        copyright_status: CreateMETSPackage::COPYRIGHT_STATUS[@job['copyright']],
        publication_status: CreateMETSPackage::PUBLICATION_STATUS[@job['copyright']]
      }
    end

    # Build actual METS XML from all the pieces
    def mets_xml
      xml = head
      xml += extra_dmdsecs
      xml += bibliographic
      xml += administrative
      xml += filegroup_sections
      xml += structure_section_physical
      xml += structure_section_logical
      Nokogiri::XML(root(xml), &:noblanks).to_xml(encoding:'utf-8')
    end

    # Root element wrapper for METS XML
    def root(xml)
       %Q(<mets:mets xmlns:mets="http://www.loc.gov/METS/"
                     xmlns:rights="http://www.loc.gov/rights/"
                     xmlns:xlink="http://www.w3.org/1999/xlink"
                     xmlns:lc="http://www.loc.gov/mets/profiles"
                     xmlns:bib="http://www.loc.gov/mets/profiles/bibRecord"
                     xmlns:mods="http://www.loc.gov/mods/v3"
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     OBJID="loc.afc.afc9999005.1153"
                     xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">#{xml}</mets:mets>)
    end

    # METS XML header information
    #  Creator and archivist
    def head
      %Q{<mets:metsHdr ID="#{mets_data[:id]}"
                     CREATEDATE="#{mets_data[:created_at]}" LASTMODDATE="#{mets_data[:updated_at]}"
                     RECORDSTATUS="complete">
        <mets:agent ROLE="CREATOR" TYPE="ORGANIZATION" ID="#{mets_data[:creator_sigel]}">
         <mets:name>#{mets_data[:creator_name]}</mets:name>
        </mets:agent>
        <mets:agent ROLE="ARCHIVIST" TYPE="ORGANIZATION" ID="#{mets_data[:archivist_sigel]}">
         <mets:name>#{mets_data[:archivist_name]}</mets:name>
        </mets:agent>
       </mets:metsHdr>}
    end

    # METS XML administrative information
    #  Copyright/publication status
    def administrative
      %Q(<mets:amdSec ID="amdSec1" >
        <mets:rightsMD ID="rightsDM1">
         <mets:mdWrap MDTYPE="OTHER">
          <mets:xmlData>
           <copyright copyright.status="#{mets_data[:copyright_status]}" publication.status="#{mets_data[:publication_status]}" xsi:noNamespaceSchemaLocation="http://www.cdlib.org/groups/rmg/docs/copyrightMD.xsd"/>
          </mets:xmlData>
         </mets:mdWrap>
        </mets:rightsMD>
       </mets:amdSec>)
    end

    # METS XML bibliographic information
    #  Translated (if necessary) output of source XML data
    #
    # Content handled by @source
    def bibliographic
      %Q(<mets:dmdSec ID="dmdSec1" CREATED="#{mets_data[:created_at]}">
        <mets:mdWrap MDTYPE="#{@source.xml_type}">
         <mets:xmlData>
          #{@source.xml_data}
         </mets:xmlData>
        </mets:mdWrap>
       </mets:dmdSec>)
    end

    # METS XML Special dmdSec:s for image data for manuscript sources
    #
    # Content handled by @source
    def extra_dmdsecs
      @source.extra_dmdsecs
    end

    # METS XML file section
    #  Single file entry with id, mimetype, path/name and checksum
    def file_section(file_group, file)
      %Q(<mets:file ID="#{file_group.name}#{file.number}"
                    MIMETYPE="#{file_group.mimetype}"
                    CHECKSUMTYPE="SHA-512"
                    CHECKSUM="#{file.checksum}">
           <mets:FLocat LOCTYPE="URL" xlink:href="#{file_group.name}/#{file.name}" />
         </mets:file>)
    end

    # METS XML file group section
    #  Single file group entry collecting files
    def filegroup_section(file_group)
      file_data = file_group.files.map do |file|
        file_section(file_group, file)
      end
      %Q("<mets:fileGrp USE="#{file_group.name}">#{file_data.join("")}</mets:fileGrp>")
    end

    # METS XML file group sections
    #  Wrapper for all file group sections
    def filegroup_sections
      file_group_data = @file_groups.map do |file_group|
        filegroup_section(file_group)
      end
      %Q(<mets:fileSec ID="fileSec1">#{file_group_data.join("")}</mets:fileSec>)
    end

    # METS XML structure section for logical structure
    #  Single entry for one image, and its logical content information
    #  Titlepage/Image/Text
    def structure_image_logical(image)
      image_num = image['num']
      image_group = image['group_name']
      dmdid = @source.dmdid_attribute(image_group)

      image_filegroup_data = @file_groups.map do |file_group|
        next '' if file_group.single?
        "<mets:fptr FILEID=\"#{file_group.name}#{sprintf("%04d", image_num)}\"/>"
      end

      %Q(<mets:div TYPE="#{image['page_content']}"
                   ID="logical_divpage#{page[:num]}"
                   ORDER="#{page[:num]}"#{dmdid}>
           #{image_filegroup_data.join("")}
         </mets:div>)
    end

    # METS XML structure section for physical structure
    #  Single entry for one image, and its physical type information
    #  Right/Left/"Cover"/...
    def structure_image_physical(image)
      image_num = image['num']
      image_filegroup_data = @file_groups.map do |file_group|
        next '' if file_group.single?
        "<mets:fptr FILEID=\"#{file_group.name}#{sprintf("%04d", image_num)}\"/>"
      end

      %Q(<mets:div TYPE="#{image['page_type']}"
                   ID="physical_divpage#{page[:num]}"
                   ORDER="#{page[:num]}">
           #{image_filegroup_data.join("")}
         </mets:div>)
    end

    # METS XML structure for logical entries
    #  Wrapper for all logical structure entries
    def structure_section_logical
      structure_data = @job['images'].map do |image| 
        structure_image_logical(image)
      end

      %Q(<mets:structMap TYPE="Logical">
           <mets:div TYPE="#{@source.type_of_record}">
             #{structure_data}
           </mets:div>
         </mets:structMap>)
    end

    # METS XML structure for physical entries
    #  Wrapper for all physical structure entries
    def structure_sections_physical
      structure_data = @job['images'].map do |image| 
        structure_image_physical(image)
      end

      %Q(<mets:structMap TYPE="Physical">
           <mets:div TYPE="#{@source.type_of_record}">
             #{structure_data}
           </mets:div>
         </mets:structMap>)
    end
  end
end

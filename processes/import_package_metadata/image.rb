require 'nokogiri'

module ImportPackageMetadata
  class Image
    attr_accessor :physical, :logical, :error

    PHYSICAL = {
      1 => "LeftPage",
      2 => "RightPage",
      4 => "BookCover",
      8 => "Foldout",
      128 => "BookSpine",
      512 => "ColorTarget",
      1024 => "LoosePage",
      16 => "DoublePage"
    }
    LOGICAL = {
      1 => "Index",
      2 => "Illustration",
      4 => "TitlePage",
      16 => "TableOfContents",
      32 => "EmptyPage"
    }

    def initialize(dfile_api:, job_id:, group_names:, image_count:, image_num:)
      @dfile_api = dfile_api
      @job_id = job_id
      @group_names = group_names
      @image_count = image_count
      @image_num = image_num
      @error = {}
    end

    # Executes model
    def run
      begin
        fetch_metadata
      rescue StandardError => e
        #@error[:msg] = e.msg
        if @error.empty?
          @error[:code] = "IMAGE_ERROR_UNKNOWN"
          @error[:msg] = "Unknown Image error"
        end
      end
    end

    def valid?
      @error.empty?
    end

    # Fetch XML metadata for image and extract relevant information
    def fetch_metadata
      image_name = sprintf("%04d.xml", @image_num)
      image_data = @dfile_api.download_file("PACKAGING", 
        "/#{@job_id}/page_metadata/#{image_name}")
      
      doc = Nokogiri::XML(image_data)
      pos = doc.search("/ParametersPage/position")
      physical_numeric = pos.search("bookside").text.to_i
      logical_numeric = pos.search("pageContent").text.to_i
      group_name = doc.search("/ParametersPage/groupName").text.to_i
      
      @physical = map_physical(physical_numeric: physical_numeric)
      @logical = map_logical(logical_numeric: logical_numeric)
      
      validate_group_name(group_name: group_name) unless group_name == 0
      @group_name = group_name
    end

    # Remap physical page definition from numeric to string
    # All physical pages must be defined
    #
    # Covers can only be first two and last two pages
    # Cover structure:
    # Page 1 => FrontCoverOutside
    # Page 2 => FrontCoverInside
    # Page N-1 => BackCoverInside
    # Page N => BackCoverOutside
    # Any other page, not allowed as cover...
    def map_physical(physical_numeric:)
      physical = PHYSICAL[physical_numeric]
      if physical == "BookCover"
        case @image_num
        when 1
          physical = "FrontCoverOutside"
        when 2
          physical = "FrontCoverInside"
        when @image_count - 1
          physical = "BackCoverInside"
        when @image_count
          physical = "BackCoverOutside"
        else
          physical = "Undefined"
          @error ||= {}
          @error[:code] = "IMAGE_COVER_ERROR"
          @error[:msg] = "Cover not in proper place: #{@image_num}"
          raise StandardError, "Cover not in proper place: #{@image_num}"
        end
      end
      if !physical
        physical = "Undefined" 
        @error ||= {}
        @error[:code] = "IMAGE_PHYSICAL_ERROR"
        @error[:msg] = "Image missing physical page definition: #{@image_num}"
        raise StandardError, "Image missing physical page definition: #{@image_num}"
      end
      physical
    end

    # Remap logical page definition from numeric to string
    def map_logical(logical_numeric:)
      logical = LOGICAL[logical_numeric]
      logical = "Undefined" if !logical
      logical
    end

    def validate_group_name(group_name:)
      if !@group_names.include?(group_name)
        @error[:code] = "IMAGE_GROUP_NAME_ERROR"
        @error[:msg] = "Image group name missing: #{@image_num}"
        raise StandardError, "Image group name missing: #{@image_num}"
      else
        return true
      end
    end
  end

  class Images
    attr_accessor :page_count, :images

    def initialize(dfile_api: dfile_api, job: job)
      @dfile_api = dfile_api
      @images = []
      @job = job
    end

    def run
      fetch_page_count
      extract_group_names
      fetch_images
    end
    
    # Retrieves page count from text file for job
    def fetch_page_count
      page_count_data = @dfile_api.download_file("PACKAGING", 
        "/#{@job['id']}/page_count/#{@job['id']}.txt")
      @page_count = page_count_data.to_i
    end

    # Extracts valid group names from job xml
    def extract_group_names
      doc = Nokogiri::XML(@job['xml'])
      @group_names = []
      doc.search('/manuscript/letter/data/imagedata').each do |imagedata|
        @group_names << imagedata.attr('hd-id').to_i
      end
    end

    # Creates image objects for each page number
    def fetch_images
      @page_count.times do |page_num| 
        @images << Image.new(dfile_api: @dfile_api, job_id: @job['id'], group_names: @group_names, image_count: @page_count, image_num: page_num+1)
      end
    end
  end
end

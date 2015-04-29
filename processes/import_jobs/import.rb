require 'spreadsheet'

module ImportJobs

  # Entry for single job to be created
  class JobEntry
    attr_reader :catalog_id
    attr_accessor :job_data

    # Collect base job data
    def initialize(dflow_api:, treenode_id:, copyright:, columns:, row:)
      @dflow_api = dflow_api
      @treenode_id = treenode_id
      @copyright = copyright
      @file_data = Hash[columns.zip(row)]
      @name = @file_data["name"]
      @catalog_id = @file_data["catalog_id"]
      @file_data.delete("name")
      @file_data.delete("catalog_id")
    end

    # Generate a complete job data before created
    def full_data
      @job_data["name"] = @name if @name
      @job_data["metadata"] ||= {}
      @job_data["metadata"].merge!(@file_data)
      @job_data["source"] = @job_data["source_name"].dup
      @job_data.delete("source_name")
      @job_data
    end
    
    # Actually send data to dFlow
    def create
      job = full_data
      job["treenode_id"] = @treenode_id
      job["copyright"] = @copyright
      @dflow_api.create_job(job: job)
    end
  end

  # Importing job list from Excel file
  class Import
    def initialize(dflow_api:, source_name:, filename:, treenode_id:, copyright:)
      @dflow_api = dflow_api
      @source_name = source_name
      @treenode_id = treenode_id
      @copyright = copyright
      @filename = filename
      @columns = []
      @jobs = []
      Spreadsheet.client_encoding = 'UTF-8'
      @excel = Spreadsheet.open(@filename)
      
      @sheet = @excel.worksheet(0)

      # Build job entry for each line, ignoring header lines
      @sheet.to_a.each.with_index do |row,i|
        # First line has column names
        if i == 0 
          @columns = row
          next
        end
        # Two more lines are placeholders for information about spreadsheet, and needs to be ignored
        next if i == 1 || i == 2

        @jobs << JobEntry.new(dflow_api: @dflow_api,
                              treenode_id: @treenode_id,
                              copyright: @copyright,
                              columns: @columns,
                              row: row)
      end

      # Extract unique list of catalog ids in file
      @catalog_ids = @jobs.map(&:catalog_id).uniq

      # Fetch only once for each catalog id and store
      @catalog_data = {}
      @catalog_ids.each do |catalog_id| 
        @catalog_data[catalog_id] = @dflow_api.get_source_data(source_name: @source_name, catalog_id: catalog_id)
      end

      # Write source data back to job entry
      @jobs.each do |job| 
        job.job_data = @catalog_data[job.catalog_id].dup
      end
      
      # Create each job in turn
      @jobs.each.with_index do |job,i| 
        job.create
      end
    end
  end
end

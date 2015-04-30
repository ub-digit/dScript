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
      @full_data_generated = false
    end

    # Generate a complete job data before created
    def generate_full_data
      return @job_data if @full_data_generated
      @job_data["name"] = @name if @name
      @job_data["metadata"] ||= {}
      @job_data["metadata"].merge!(@file_data)
      @job_data["source"] = @job_data["source_name"].dup
      @job_data.delete("source_name")
      @full_data_generated = true
      @job_data
    end
    
    # Actually create job in dFlow
    def create(validate_only: false)
      job = generate_full_data
      job["treenode_id"] = @treenode_id
      job["copyright"] = @copyright
      params = {}
      params[:validate_only] = true if validate_only
      @dflow_api.create_job(job: job, params: params)
    end

    # Check with dFlow if job would be valid to create or not. Return error if not valid.
    def invalid?
      response = create(validate_only: true)
      return response['error'] if response['error']
      false
    end
  end

  # Importing job list from Excel file
  class Import
    def initialize(sh: sh, dflow_api:, source_name:, filename:, treenode_id:, copyright:)
      @sh = sh
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

      # Validate jobs
      jobs_validity = @jobs.map.with_index do |job,i|
        error = job.invalid?
        next if !error
        [error, i]
      end.compact

      # If any job failed validation, write a report and terminate
      if !jobs_validity.empty?
        puts "==============================="
        puts "ERROR! Not all jobs were valid."
        puts "Invalid rows in file:"
        jobs_validity.each do |row|
          error = row[0]
          row_num = row[1] + 4
          puts "Row: #{row_num}: #{error['code']} #{error['errors'].inspect}"
        end
        puts "==============================="
        @sh.terminate("ERROR!Not all jobs were valid. Aborting.")
      end
      
      # Create each job in turn when everything is validated as correct
      @jobs.each.with_index do |job,i| 
        job.create
      end
    end
  end
end

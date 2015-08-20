require 'httparty'
require 'pp'
require 'json'

module DScript
	class DFlowAPI

   def initialize(helper, process_code)
     @host = DScript::DFLOW_URL
     @api_key = DScript::DFLOW_API_KEY
     @helper = helper
     @process_code = process_code
     check_connection
   end

   # Returns true of connection is successful
   def check_connection
     return
     check = HTTParty.get("#{@host}/api/process/check_connection?api_key=#{@api_key}")
     if check.nil? || check["status"]["code"] < 0
       @helper.terminate("Script was unable to establish connection with dFlow at #{@host}")
     end
   end

   # Returns a job to process, if any is available
   def request_job_to_process
     
     response = HTTParty.get("#{@host}/api/process/request_job/#{@process_code}.json", query: {
       api_key: @api_key
     })

     job = response["job"]
     #If there is no job waiting, end script
     if job.nil? || job["id"].to_i == 0 
       @helper.terminate("No job to process at this time")
     else
       @helper.log("Starting process #{@process_code} for job: #{job["id"]} - #{job["author"]} - #{job["title"]} - #{job["created_at"]}")
     end
     return job
   end

   # TODO: Needs error handling
   def update_process(job_id:, step:, status:, msg:)
     HTTParty.get("#{@host}/api/process/#{job_id}", query: {
       process_code: @process_code,
       step: step,
       status: status,
       msg: msg,
       api_key: @api_key
     })
   end

   # Return  a single job
   def find_job(job_id)
     response = HTTParty.get("#{@host}/api/jobs/#{job_id}")

     return response['job']
   end

   # Updates a job with new information
   def update_job(job:)
     response = HTTParty.put("#{@host}/api/jobs/#{job[:id]}", body: {job: job, api_key: @api_key})
     
     return response.success?
   end

   # Create a new job
   def create_job(job:, params: {})
     response = HTTParty.post("#{@host}/api/jobs", body: {job: job, api_key: @api_key}.merge(params))
     
     return response
   end

   # Fetch source data for catalog id
   def get_source_data(source_name:, catalog_id:)
     response = HTTParty.get("#{@host}/api/sources/#{source_name}", query: {
       catalog_id: catalog_id,
       api_key: @api_key
     })
     
     return response["source"]
   end

    # Find jobs for given parameter hash
    def find_jobs(params:)
      response = HTTParty.get("#{@host}/api/jobs", query: params)

      return response["jobs"]  
    end

    # Create publication log item
    def create_publication_log(params:)
      response = HTTParty.post("#{@host}/api/publication_log", body: {publication_log: params}.merge({api_key: @api_key}))
     
      return response
    end

    # Find unpublished jobs
    # PARAMS: publication_type, source, copyright
    def find_unpublished_jobs(params:)
      response = HTTParty.get("#{@host}/api/jobs/unpublished_jobs", query: params)
      
      return response['jobs']
    end

	end
end

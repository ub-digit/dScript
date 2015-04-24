require 'httparty'

module DScript
	class DFlowAPI

   def initialize(helper, process_code)
     @host = DScript::DFLOW_URL
     @api_key = DScript::DFILE_API_KEY
     @helper = helper
     @process_code = process_code
     check_connection
   end

   # Returns true of connection is successful
   def check_connection
     return
     check = HTTParty.get("#{@host}/api/check_connection?api_key=#{@api_key}")
     if check.nil? || check["status"]["code"] < 0
       @helper.terminate("Script was unable to establish connection with dFlow at #{@host}")
     end
   end

   def request_job_to_process
     # Returns a job to process, if any is available
     job = HTTParty.get("#{@host}/api/process/request_job/#{@process_code}", {
       api_key: @api_key
     }) 

     #If there is no job waiting, end script
     if job.nil? || job["id"].to_i == 0 
       @helper.terminate("No job to process at this time")
     else
       @helper.log("Starting process #{@process_code} for job: #{job["id"]} - #{job["author"]} - #{job["title"]} - #{job["created_at"]}")
     end
     return job
   end

   # TODO: Needs error handling
   def update_process(job_id, status, msg)
     HTTParty.post("#{@host}/api/process/#{job_id}", body: {
       process_code: @process_code,
       status: status,
       msg: msg
     })
   end
	end
end

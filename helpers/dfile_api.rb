require 'httparty'

module DScript
	class DFileAPI

   def initialize(helper, process_code)
     @host = DScript::DFILE_URL
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
       @helper.terminate("Script was unable to establish connection with dFile at #{@host}")
     end
   end

   # TODO: Needs error handling
   def download_file(source, filename)
     # Returns a job to process, if any is available
     response = HTTParty.get("#{@host}/download_file", query: {
       source_file: "#{source}:#{filename}",
       api_key: @api_key
     })
     
     return response.body
   end
	end
end


module DScript
	class ScriptHelper
		
		def initialize
			@starttime = Time.now
		end
		#Method for log outputs
		def log(message)
			puts message
		end

		#Method for terminating the script
		def terminate(message)
			log("End: " + message)
			log("Script runtime: #{(Time.now - @starttime).to_i} seconds")
			exit
		end

	end
end

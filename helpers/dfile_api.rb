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
       response = HTTParty.get("#{@host}/download_file", query: {
         source_file: "#{source}:#{filename}",
         api_key: @api_key
         })
       
       return response.body
     end

     # TODO: Needs error handling
     # Returns array of {:name, :size}
     # :name == basename
     def list_files(source, directory, extension)
       response = HTTParty.get("#{@host}/list_files", query: {
         source_dir: "#{source}:#{directory}",
         ext: extension,
         api_key: @api_key
         })

       return response
     end

    # TODO: Needs error handling
    def move_file(from_source:, from_file:, to_source:, to_file:)
      response = HTTParty.get("#{@host}/move_file", query: {
        source_file: "#{from_source}:#{from_file}",
        dest_file: "#{to_source}:#{to_file}",
        api_key: @api_key
        })
     
      return response.body
    end

    # TODO: Needs error handling
    def move_folder(from_source:, from_dir:, to_source:, to_dir:)
      response = HTTParty.get("#{@host}/move_folder", query: {
        source_dir: "#{from_source}:#{from_dir}",
        dest_dir: "#{to_source}:#{to_dir}",
        api_key: @api_key
        })
     
      return response.success?
    end

    # TODO: Needs error handling
    # returns {:checksum, :msg}
    def checksum(source, filename)
      response = HTTParty.get("#{@host}/checksum", query: {
        source_file: "#{source}:#{filename}",
        api_key: @api_key
        })

      return response['checksum']
    end

    # Creates a file with given content
    def create_file(source:, filename:, content:, permission: nil)
      body = { dest_file: "#{source}:#{filename}",
        content: content,
        api_key: @api_key
      }
      if !permission.blank?
        body['permission'] = permission
      end

      response = HTTParty.post("#{@host}/create_file", body: body)

      return response.success?
    end

    # Copies a file
    def copy_file(from_source:, from_file:, to_source:, to_file:)
      response = HTTParty.get("#{@host}/copy_file", query: {
        source_file: "#{from_source}:#{from_file}",
        dest_file: "#{to_source}:#{to_file}",
        api_key: @api_key
      })

      return response.success?
    end
  end
end

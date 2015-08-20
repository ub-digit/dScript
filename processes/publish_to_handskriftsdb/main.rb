#!/usr/bin/env ruby
require 'bundler'
require_relative '../../helpers/dscript_helper.rb'
require_relative '../../helpers/dfile_api.rb'
require_relative '../../helpers/dflow_api.rb'
require_relative '../../config.rb'
require_relative 'handskriftsdb'

PROCESS_CODE = nil 
####### INITIALIZERS #################
@sh = DScript::ScriptHelper.new
@dflow_api = DScript::DFlowAPI.new(@sh, PROCESS_CODE)
@dfile_api = DScript::DFileAPI.new(@sh, PROCESS_CODE)
######################################

# Find jobs without publicationlog 'MANUSCRIPT'
params = {
  sources: ["document", "letter"],
  missing_publication_type: "MANUSCRIPT",
  state: "FINISH"
}
@jobs = @dflow_api.find_jobs(params: params)

pp @jobs.first
pp @jobs.count


@jobs.each do |job|

  # If comment includes COPIED string, file have already been copied and publication log entry can be created.
  if job['comment'].include? "COPIED"
    puts "jobb #{job['id']} redan kopierat"
    # Interpret date from comment
    comment = job['comment']
    index = comment.index('COPIED') + 7
    datestring = comment[index, 25]
    date = DateTime.iso8601(datestring)
    pp date
    publication_log = {
      job_id: job['id'],
      created_at: date,
      publication_type: 'MANUSCRIPT',
      comment: ''
    }
    @dflow_api.create_publication_log(params: publiation_log)
    exit
    next
  end
  puts job['id']
end

#begin
#  mets = CreateMETSPackage::METS.new(dfile_api: @dfile_api, job: @job)
#  mets.create_mets_xml_file
#  mets.move_metadata_folders
#  mets.move_mets_package
#  @dflow_api.update_process(job_id: @job['id'], step: @job['current_flow_step'], status: 'success', msg: 'Mets package successfully created!')
#rescue StandardError => e
#  @dflow_api.update_process(job_id: @job['id'], step: @job['current_flow_step'], status: 'fail', msg: e.message)
#  @sh.terminate(e.message)
#end



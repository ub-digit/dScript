#!/usr/bin/env ruby
require 'bundler'
require_relative '../../helpers/dscript_helper.rb'
require_relative '../../helpers/dfile_api.rb'
require_relative '../../helpers/dflow_api.rb'
require_relative '../../config.rb'
require_relative 'image'

PROCESS_CODE = "PACKAGE_METADATA_IMPORT"
####### INITIALIZERS #################
@sh = DScript::ScriptHelper.new
@dflow_api = DScript::DFlowAPI.new(@sh, PROCESS_CODE)
@dfile_api = DScript::DFileAPI.new(@sh, PROCESS_CODE)
######################################


# Get job that is waiting for processing
# Run when:
#  Job exists where status == waiting_for_package_metadata_import
@job = @dflow_api.request_job_to_process
images = ImportPackageMetadata::Images.new(dfile_api: @dfile_api, job: @job)
images.run

if images.valid?
  # Store metadata information to job
  new_job = {id: @job['id'], package_metadata: {images: images.images.map(&:as_json), image_count: images.images.size}.to_json}
  @dflow_api.update_job(job: new_job)

  # Update progress
  @dflow_api.update_process(job_id: @job['id'], status: 'success', msg: 'Metadata successfully imported!')
else
  @dflow_api.update_process(job_id: @job['id'], status: 'fail', msg: images.errors.inspect)
end

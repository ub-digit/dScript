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
ImportPackageMetadata::Images.new(@dfile_api, @job)


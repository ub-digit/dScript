#!/usr/bin/env ruby
require_relative '../../helpers/dscript_helper.rb'
require_relative '../../helpers/dflow_api.rb'
require_relative '../../config.rb'

PROCESS_CODE = "rename_files"
####### INITIALIZERS #################
@sh = DScript::ScriptHelper.new
@dflow_api = DScript::DFlowAPI.new(@sh, PROCESS_CODE)
######################################


# Get job that is waiting for processing
@job = @dflow_api.request_job_to_process


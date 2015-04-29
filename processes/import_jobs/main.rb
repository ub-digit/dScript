#!/usr/bin/env ruby
require 'bundler'
require_relative '../../helpers/dscript_helper.rb'
require_relative '../../helpers/dfile_api.rb'
require_relative '../../helpers/dflow_api.rb'
require_relative '../../config.rb'
require_relative 'import'

PROCESS_CODE = "IMPORT_JOBS"
####### INITIALIZERS #################
@sh = DScript::ScriptHelper.new
@dflow_api = DScript::DFlowAPI.new(@sh, PROCESS_CODE)
@dfile_api = DScript::DFileAPI.new(@sh, PROCESS_CODE)
######################################


# Get job that is waiting for processing
# Run when:
#  Job exists where status == waiting_for_package_metadata_import
@import = ImportJobs::Import.new(dflow_api: @dflow_api,
                                 source_name: "libris",
                                 filename: "/tmp/1913-14.xls",
                                 treenode_id: 4,
                                 copyright: true
                                )


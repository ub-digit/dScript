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

def usage
  puts "\n"
  puts "Usage: import_jobs filename.xls source_name treenode_id copyright"
  puts "\n\n"
  exit
end

if !ARGV[3] || ARGV[3].empty?
  usage
  exit
end

if !ARGV[0] || ARGV[0].empty?
  usage
elsif !File.exist?(ARGV[0])
  puts "No such file: #{ARGV[0]}"
  exit
else
  @filename = ARGV[0]
end

if !ARGV[1] || ARGV[1].empty?
  usage
else
  @source_name = ARGV[1]
end

if !ARGV[2] || ARGV[2].empty?
  usage
else
  @treenode_id = ARGV[2]
end

if !ARGV[3] || ARGV[3].empty?
  usage
else
  if ARGV[3] == "false"
    @copyright = false
  else
    @copyright = true
  end
end

@import = ImportJobs::Import.new(sh: @sh,
                                 dflow_api: @dflow_api,
                                 source_name: @source_name,
                                 filename: @filename,
                                 treenode_id: @treenode_id,
                                 copyright: @copyright)


#!/usr/bin/env ruby
require 'bundler'
require_relative '../../helpers/dscript_helper.rb'
require_relative '../../helpers/dfile_api.rb'
require_relative '../../helpers/dflow_api.rb'
require_relative '../../config.rb'
require_relative 'gupea_package'

PROCESS_CODE = "GUPEA_IMPORT"
####### INITIALIZERS #################
@sh = DScript::ScriptHelper.new
@dflow_api = DScript::DFlowAPI.new(@sh, PROCESS_CODE)
@dfile_api = DScript::DFileAPI.new(@sh, PROCESS_CODE)
######################################

# Find jobs which may be relevant for publication
jobs = @dflow_api.find_unpublished_jobs(params: {publication_type: 'GUPEA', source: ['Libris'], copyright: false})

pp jobs.count

# Filter jobs which belong to a treenode with a configured GUPEA-collection
gupea_config = YAML.load(@dfile_api.download_file('CONFIGURATION', 'gupea_collections.yml'))
jobs = jobs.select{|job| gupea_config.keys.include?(job['treenode_id'])}

puts jobs.count
# Identify jobs which have already been published the old way
jobs_already_published = jobs.select{|job| job['comment'].index("GUPEA")}

puts jobs_already_published.count

# Create publication logs for old jobs
jobs_already_published.each do |job|

  comment = job['comment']
  
  values = comment.scan(/\[GUPEA (\S+) (\S+) \]/).first
  date = DateTime.iso8601(values[0])
  link = values[1]

  publication_log = {
    job_id: job['id'],
    created_at: date,
    publication_type: 'GUPEA',
    comment: link
  }

  @dflow_api.create_publication_log(params: publication_log)
end

# Identify jobs to be published
jobs_to_publish = jobs - jobs_already_published
puts jobs_to_publish.count

# Publish jobs
jobs_to_publish.each do |job|
  # Fetch full job
  full_job = @dflow_api.find_job(job['id'])
  package = GupeaPackage::Package.new(full_job, @dfile_api, gupea_config[full_job['treenode_id']])
  package.create_xml
  package.create_folder
end

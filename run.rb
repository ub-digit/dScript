#!/usr/bin/env ruby
require 'rbconfig'
require 'bundler'
require 'pathname'
THIS_FILE = File.expand_path(__FILE__)
RUBY = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
Dir["./helpers/*.rb"].each {|file| require file }

@sh = DScript::ScriptHelper.new # Init scripthelper

start_script_name = $0
if start_script_name == "./run.rb"
	# If script is called for run.rb, use first argument as process_name
	call_process = ARGV[0]
else
	# If script is called from another file, use its name as process name
	call_process = File.basename(start_script_name)
end

# Check if process folder exists
if !call_process || call_process.empty?
	@sh.terminate("No process is assigned")
elsif !File.directory?("./processes/#{call_process}")
	@sh.terminate("No process implemented with name: #{call_process}")
end

# Check if main routine exists
if !File.file?("./processes/#{call_process}/main.rb")
	@sh.terminate("No 'main.rb' script file was found for process #{call_process}")
end

script_file = Pathname.new("./processes/#{call_process}/main.rb")

cmd = "#{RUBY} #{script_file.to_s}"
IO.popen(cmd).each do |subprocess|
	 print subprocess
end

@sh.terminate("Script ended")

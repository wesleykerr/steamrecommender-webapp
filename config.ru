require File.expand_path 'app.rb'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application

require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'

require 'routes/init.rb'

get '/' do
  "Worked on dreamhost"
  haml :index
end

get '/foo/:bar' do
  "You asked for foo/#{params[:bar]}"
end


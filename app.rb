require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml'
require 'haml'

require 'models/init.rb'
require 'routes/init.rb'

get '/' do
  haml :index
end

get '/foo/:bar' do
  "You asked for foo/#{params[:bar]}"
end


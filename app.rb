require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml'
require 'haml'

require 'models/init.rb'
require 'routes/init.rb'
require 'recomms.rb'

configure do
  @@matrix_recomms = MatrixRecomms.new
end

get '/' do
  @title = 'Steam Recommender'
  haml :index
end



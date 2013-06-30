require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml'
require 'haml'
require 'data_mapper'

require 'routes/init.rb'

config_obj = YAML::load( "#{File.expand_path(__FILE__)}../config/steamrecommender.yml" )
user = config_obj['mysql_user']
pass = config_obj['mysql_password']

DataMapper.setup(:default, "mysql://#{user}:#{pass}@mysql.seekerr.com/game_recommender")

get '/' do
  haml :index
end

get '/foo/:bar' do
  "You asked for foo/#{params[:bar]}"
end

